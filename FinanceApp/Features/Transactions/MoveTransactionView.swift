//
//  MoveTransactionView.swift
//  FinanceApp
//

import SwiftUI
import SwiftData

struct MoveTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query var budgets: [Budget]
    @State private var expandedBudgets: Set<UUID> = []
    @State private var showPopup = false
    @State private var pendingDestination: MoveDestination?

    let close: () -> ()
    let transaction: Transaction

    enum MoveDestination {
        case budgetItself(Budget)
        case subBudget(SubBudget)
        case unassign(fromBudgetName: String)
    }

    private var currentBudget: Budget? {
        for budget in budgets {
            guard budget.budgetName != unassignedBudgetName else { continue }
            for sub in budget.subBudgets {
                if sub.transactions.contains(where: { $0.id == transaction.id }) { return budget }
            }
        }
        return nil
    }

    private var visibleBudgets: [Budget] {
        budgets.filter { $0.budgetName != unassignedBudgetName }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // Handle + title
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 4)

                    HStack {
                        GlowText(transaction.location_spent, font: .title3.weight(.semibold), glowColors: [.electricBlue, .hotPink])
                        Spacer()
                        Button(action: close) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.white.opacity(0.3))
                        }
                    }

                    Text("Move to…")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.08))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(visibleBudgets) { budget in
                            budgetSection(budget)
                        }

                        // Unassign option
                        if let current = currentBudget {
                            Button {
                                pendingDestination = .unassign(fromBudgetName: current.budgetName)
                                showPopup = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "minus.circle")
                                        .foregroundStyle(Color.hotPink.opacity(0.8))
                                    Text("Remove from \"\(current.budgetName)\"")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.hotPink.opacity(0.8))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .glassCard(cornerRadius: 14, accent: .hotPink)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 12)
                }
            }

            if showPopup, let destination = pendingDestination {
                PopUpView(
                    title: "Move Transaction",
                    message: popupMessage(for: destination),
                    buttonTitle: "Confirm",
                    buttonAction: {
                        Task { await performMove(destination: destination) }
                        showPopup = false
                        dismiss()
                    },
                    closeAction: { showPopup = false }
                )
            }
        }
        .presentationBackground { AppBackground() }
    }

    @ViewBuilder
    private func budgetSection(_ budget: Budget) -> some View {
        let isExpanded = expandedBudgets.contains(budget.id)

        VStack(spacing: 0) {
            // Budget header row
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if isExpanded { expandedBudgets.remove(budget.id) }
                    else { expandedBudgets.insert(budget.id) }
                }
            } label: {
                HStack {
                    Text(budget.budgetName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            if isExpanded {
                Divider().background(Color.white.opacity(0.08)).padding(.horizontal, 12)

                // Main bucket
                Button {
                    pendingDestination = .budgetItself(budget)
                    showPopup = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "tray")
                            .foregroundStyle(Color.electricBlue.opacity(0.7))
                            .font(.subheadline)
                        Text(budget.budgetName + " (general)")
                            .font(.subheadline)
                            .foregroundStyle(Color.electricBlue.opacity(0.85))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(Color.electricBlue.opacity(0.4))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
                }

                ForEach(budget.namedSubBudgets) { sub in
                    Divider().background(Color.white.opacity(0.06)).padding(.horizontal, 12)
                    Button {
                        pendingDestination = .subBudget(sub)
                        showPopup = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "folder")
                                .foregroundStyle(Color.white.opacity(0.3))
                                .font(.subheadline)
                            Text(sub.title)
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.7))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(Color.white.opacity(0.25))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 11)
                    }
                }
            }
        }
        .glassCard(cornerRadius: 16, accent: isExpanded ? .electricBlue : nil)
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.3), value: isExpanded)
    }

    private func popupMessage(for destination: MoveDestination) -> String {
        switch destination {
        case .unassign(let name):
            return "Remove this transaction from \"\(name)\"?"
        case .budgetItself(let budget):
            return "Move to \"\(budget.budgetName)\"?"
        case .subBudget(let sub):
            return "Move to \"\(sub.title)\"?"
        }
    }

    private func performMove(destination: MoveDestination) async {
        let target: SubBudget?
        switch destination {
        case .budgetItself(let budget):
            target = ensureMainSubBudget(for: budget)
        case .subBudget(let sub):
            target = sub
        case .unassign:
            target = budgets.first(where: { $0.budgetName == unassignedBudgetName })?.mainSubBudget
        }
        guard let target else { return }
        TransactionService.moveTransaction(transaction: transaction, to: target, context: context)
        let sync = SyncService(context: context)
        try? await sync.moveTransaction(transaction, to: target)
    }

    private func ensureMainSubBudget(for budget: Budget) -> SubBudget {
        if let existing = budget.mainSubBudget { return existing }
        let main = SubBudget(title: "")
        context.insert(main)
        budget.subBudgets.append(main)
        try? context.save()
        return main
    }
}

#Preview {
    let container = try! ModelContainer(for: Budget.self, SubBudget.self, Transaction.self)
    SampleDataSeeder.seed(context: ModelContext(container))
    return MoveTransactionView(close: {}, transaction: sampleTransactions[0])
        .modelContainer(container)
}
