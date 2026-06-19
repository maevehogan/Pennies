
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
    @State private var showMoveSheet: Bool = false
    @State private var transactionToMove: Transaction? = nil
    @State private var showFilterSheet: Bool = false
    @State private var filters = TransactionFilters()

    // Lookup: transaction ID → the budget it lives in
    private var transactionBudgetMap: [UUID: UUID] {
        var map: [UUID: UUID] = [:]
        for budget in budgets {
            for sub in budget.subBudgets {
                for tx in sub.transactions {
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
                case .all:                        return true
                case .specific(let id):           return budgetMap[tx.id] == id
                case .unassigned:                 return budgetMap[tx.id] == nil
                }
            }()

            let passesDate: Bool = {
                switch filters.dateFilter {
                case .all:        return true
                case .today:      return cal.isDateInToday(tx.date)
                case .thisWeek:   return tx.date >= cal.date(byAdding: .day, value: -7, to: Date())!
                case .thisMonth:  return cal.isDate(tx.date, equalTo: Date(), toGranularity: .month)
                case .custom(let start, let end):
                    return tx.date >= cal.startOfDay(for: start) && tx.date <= end
                }
            }()

            return passesBudget && passesDate
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        openTransactionId = nil
                    }
                }

            VStack(spacing: 0) {
                // Header row
                HStack(alignment: .center) {
                    filterButton
                        .padding(.leading)
                    Spacer()
                    Text("Recent Transactions")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Spacer()
                    // Invisible spacer to balance the filter button
                    Color.clear.frame(width: 44)
                }
                .padding(.vertical, 8)

                // Active filter summary chips
                if filters.isActive {
                    filterSummary
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTransactions) { transaction in
                            TransactionsItemView(
                                transaction: transaction,
                                openTransactionId: $openTransactionId,
                                onMoreTapped: {
                                    transactionToMove = transaction
                                    showMoveSheet = true
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
                    }
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            TransactionFilterSheet(filters: $filters, budgets: budgets)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMoveSheet, onDismiss: { openTransactionId = nil }) {
            if let transactionToMove = transactionToMove {
                MoveTransactionView(close: { showMoveSheet = false }, transaction: transactionToMove)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            } else {
                Text("Error Loading Data.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .italic()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                Button {
                    showMoveSheet = false
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                        .cornerRadius(10)
                }
            }
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
                    .foregroundStyle(filters.isActive ? .blue : .gray)
                if filters.activeCount > 0 {
                    Text("\(filters.activeCount)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Color.blue)
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
        .background(Color.blue.opacity(0.35))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
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
    SampleDataSeeder.reset(context: ModelContext(container))
    SampleDataSeeder.seed(context: ModelContext(container))

    return TransactionsListView()
        .modelContainer(container)
}
