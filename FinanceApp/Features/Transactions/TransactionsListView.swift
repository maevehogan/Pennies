
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    @Query var budgets: [Budget]

    @State private var openTransactionId: UUID? = nil
    @State private var transactionToMove: Transaction? = nil
    @State private var showFilterSheet: Bool = false
    @State private var showCreateSheet: Bool = false
    @State private var filters = TransactionFilters()

    let transactionPage: Bool
    var swipeEnabled: Bool = true

    // Lookup: transaction ID → the budget it lives in
    private var transactionBudgetMap: [UUID: UUID] {
        var map: [UUID: UUID] = [:]
        for budget in budgets {
            for sub in budget.subBudgets {
                for tx in sub.transactions {
                    if budget.budgetName == "__unassigned__" { continue }
                    map[tx.id] = budget.id
                }
            }
        }
        return map
    }

    private var filteredTransactions: [Transaction] {
        let budgetMap = transactionBudgetMap
        let cal = Calendar.current
        return transactions.filter { tx in
            let passesBudget: Bool = {
                switch filters.budgetFilter {
                case .all:
                    return true
                case .specific(let id):
                    return budgetMap[tx.id] == id
                case .unassigned:
                    return budgetMap[tx.id] == nil
                }
            }()

            let passesDate: Bool = {
                switch filters.dateFilter {
                case .all:
                    return true
                case .today:
                    return cal.isDateInToday(tx.date)
                case .thisWeek:
                    return tx.date >= cal.date(byAdding: .day, value: -7, to: Date())!
                case .thisMonth:
                    return cal.isDate(tx.date, equalTo: Date(), toGranularity: .month)
                case .custom(let start, let end):
                    return tx.date >= cal.startOfDay(for: start) && tx.date <= end
                }
            }()

            let passesSource: Bool = {
                switch filters.sourceFilter {
                case .all:    return true
                case .manual: return tx.source == "manual"
                case .institution(let name):
                    if name == "Connected Account" {
                        return tx.source == "plaid" && tx.institutionName == nil
                    }
                    return tx.institutionName == name
                }
            }()

            return passesBudget && passesDate && passesSource
        }
    }

    // Unique institution names from synced Plaid transactions.
    // Falls back to a generic "Connected Account" entry if any Plaid transactions
    // lack an institution name (e.g. synced before the backend change was deployed).
    private var institutionNames: [String] {
        var seen = Set<String>()
        var names = transactions.compactMap { $0.institutionName }.filter { seen.insert($0).inserted }
        let hasUnnamedPlaid = transactions.contains { $0.source == "plaid" && $0.institutionName == nil }
        if hasUnnamedPlaid { names.append("Connected Account") }
        return names
    }

    var body: some View {
        ZStack {
            if transactionPage { AppBackground() }

            // Tap background to close any open swipe card — sits below ScrollView
            // so it doesn't interfere with scroll gestures
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if openTransactionId != nil {
                        withAnimation(.spring(response: 0.3)) {
                            openTransactionId = nil
                        }
                    }
                }

            VStack(spacing: 0) {
                // Header row
                HStack(alignment: .center) {
                    if transactionPage {
                        GradientLabel("Transactions", font: .title.bold())
                        Spacer()
                        HStack(spacing: 8) {
                            Button {
                                showCreateSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.electricBlue)
                            }
                            filterButton
                        }
                    } else {
                        // Embedded in home — no header needed (HomeView provides it)
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, transactionPage ? 16 : 0)
                .padding(.bottom, 8)

                // Active filter summary chips
                if filters.isActive {
                    filterSummary
                        .padding(.horizontal)
                        .padding(.top, 6)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        Spacer().frame(height: 8)
                        ForEach(filteredTransactions) { transaction in
                            TransactionsItemView(
                                transaction: transaction,
                                openTransactionId: $openTransactionId,
                                swipeEnabled: swipeEnabled,
                                onMoreTapped: {
                                    transactionToMove = transaction
                                },
                                onDeleteTapped: {
                                    Task { await deleteTransaction(transaction) }
                                }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }

                        if filteredTransactions.isEmpty {
                            Text("No transactions match your filters.")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.subheadline)
                                .italic()
                                .padding(.top, 50)
                        }

                        if transactionPage {
                            Spacer().frame(height: 100)
                        }
                    }
                }
                .frame(maxHeight:  .infinity)
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .sheet(isPresented: $showCreateSheet) {
            CreateTransactionView(close: { showCreateSheet = false })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFilterSheet) {
            TransactionFilterSheet(filters: $filters, budgets: budgets, institutionNames: institutionNames)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $transactionToMove, onDismiss: { openTransactionId = nil }) { tx in
            MoveTransactionView(close: { transactionToMove = nil }, transaction: tx)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Filter button

    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundStyle(filters.isActive ? Color.electricBlue : Color.white.opacity(0.4))
                if filters.activeCount > 0 {
                    Text("\(filters.activeCount)")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color.electricBlue)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
            .padding(4)
        }
    }

    // MARK: Active filter chips

    private var filterSummary: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if filters.budgetFilter != .all {
                    chip(label: budgetChipLabel) {
                        filters.budgetFilter = .all
                    }
                }
                if filters.dateFilter != .all {
                    chip(label: dateChipLabel) {
                        filters.dateFilter = .all
                    }
                }
                if case .manual = filters.sourceFilter {
                    chip(label: "Manual") { filters.sourceFilter = .all }
                } else if case .institution(let name) = filters.sourceFilter {
                    chip(label: name) { filters.sourceFilter = .all }
                }
            }
        }
    }

    private var budgetChipLabel: String {
        switch filters.budgetFilter {
        case .all: return ""
        case .unassigned: return "Unassigned"
        case .specific(let id):
            return budgets.first(where: { $0.id == id })?.budgetName ?? "Budget"
        }
    }

    private var dateChipLabel: String {
        switch filters.dateFilter {
        case .all:       return ""
        case .today:     return "Today"
        case .thisWeek:  return "Last 7 Days"
        case .thisMonth: return "This Month"
        case .custom(let start, let end):
            let fmt = Date.FormatStyle().month(.abbreviated).day()
            return "\(start.formatted(fmt)) – \(end.formatted(fmt))"
        }
    }

    private func deleteTransaction(_ transaction: Transaction) async {
        let sync = SyncService(context: context)
        try? await sync.deleteTransaction(transaction)
    }

    private func chip(label: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.electricBlue.opacity(0.2))
        .overlay(
            Capsule()
                .strokeBorder(Color.electricBlue.opacity(0.5), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    let context = ModelContext(container)
    SampleDataSeeder.reset(context: context)
    SampleDataSeeder.seed(context: context)

    return TransactionsListView(transactionPage: true)
        .modelContainer(container)
}
