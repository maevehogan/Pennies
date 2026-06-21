//
//  MoveTransactionView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/19/26.
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

    let transaction: Transaction // The transaction being moved

    enum MoveDestination {
        case budgetItself(Budget)
        case subBudget(SubBudget)
        case unassign(fromBudgetName: String)
    }

    // The named budget this transaction belongs to (excludes the hidden unassigned budget)
    private var currentBudget: Budget? {
        for budget in budgets {
            guard budget.budgetName != unassignedBudgetName else { continue }
            for sub in budget.subBudgets {
                if sub.transactions.contains(where: { $0.id == transaction.id }) {
                    return budget
                }
            }
        }
        return nil
    }

    private var visibleBudgets: [Budget] {
        budgets.filter { $0.budgetName != unassignedBudgetName }
    }

    var body: some View {
        ZStack {
            VStack {
                Button {
                    // close the sheet without doing anything
                    close()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        )
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }


                List {
                ForEach(visibleBudgets, id: \.id) { budget in
                    Section {
                        BudgetRow(budget: budget, isExpanded: expandedBudgets.contains(budget.id)) {
                            toggleExpanded(budget: budget)
                        }
                        if expandedBudgets.contains(budget.id) {
                            // Always-present option: add to the budget itself (no sub-budget)
                            Button {
                                pendingDestination = .budgetItself(budget)
                                showPopup = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "tray")
                                    Text("Add to \"\(budget.budgetName)\" ")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.leading, 24)

                            ForEach(budget.namedSubBudgets, id: \.id) { subBudget in
                                Button {
                                    pendingDestination = .subBudget(subBudget)
                                    showPopup = true
                                } label: {
                                    Text(subBudget.title)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 24)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
            }
            .padding(.top, 20)

            if let budget = currentBudget {
                Button {
                    pendingDestination = .unassign(fromBudgetName: budget.budgetName)
                    showPopup = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "minus.circle")
                        Text("Remove from \"\(budget.budgetName)\"")
                            .font(.subheadline)
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                }
            }

            if showPopup, let destination = pendingDestination {
                PopUpView(
                    title: "Move Transaction",
                    message: popupMessage(for: destination),
                    buttonTitle: "Confirm",
                    buttonAction: {
                        performMove(destination: destination)
                        showPopup = false
                        dismiss() // Dismiss the sheet
                    },
                    closeAction: {
                        showPopup = false
                        // Do NOT dismiss the sheet here
                    }
                )
            }

        }
    }

    private func displayName(for destination: MoveDestination) -> String {
        switch destination {
        case .budgetItself(let budget): return budget.budgetName
        case .subBudget(let sub): return sub.title
        case .unassign(let name): return name
        }
    }

    private func popupMessage(for destination: MoveDestination) -> String {
        switch destination {
        case .unassign(let name):
            return "Are you sure you want to remove this transaction from \"\(name)\"?"
        default:
            return "Are you sure you want to move this transaction to \"\(displayName(for: destination))\"?"
        }
    }

    private func performMove(destination: MoveDestination) {
        switch destination {
        case .budgetItself(let budget):
            let target = ensureMainSubBudget(for: budget)
            TransactionService.moveTransaction(transaction: transaction, to: target, context: context)
        case .subBudget(let sub):
            TransactionService.moveTransaction(transaction: transaction, to: sub, context: context)
        case .unassign:
            TransactionService.unassignTransaction(transaction: transaction, context: context)
        }
    }

    // Older budgets persisted before the main-bucket convention won't have one.
    // Create it lazily so a "budget itself" move always has a destination.
    private func ensureMainSubBudget(for budget: Budget) -> SubBudget {
        if let existing = budget.mainSubBudget {
            return existing
        }
        let main = SubBudget(title: "")
        context.insert(main)
        budget.subBudgets.append(main)
        try? context.save()
        return main
    }

    private func toggleExpanded(budget: Budget) {
        if expandedBudgets.contains(budget.id) {
            expandedBudgets.remove(budget.id)
        } else {
            expandedBudgets.insert(budget.id)
        }
    }
}

struct BudgetRow: View {
    let budget: Budget
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(budget.budgetName)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    // Seed the preview container
    SampleDataSeeder.seed(context: ModelContext(container))

    return MoveTransactionView(close: {}, transaction: sampleTransactions[0])
        .modelContainer(container)
}
