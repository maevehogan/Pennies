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
    @State private var selectedSubBudget: SubBudget?
    
    let close: () -> ()
    
    let transaction: Transaction // The transaction being moved
    
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
                ForEach(budgets, id: \.id) { budget in
                    Section {
                        BudgetRow(budget: budget, isExpanded: expandedBudgets.contains(budget.id)) {
                            toggleExpanded(budget: budget)
                        }
                        if expandedBudgets.contains(budget.id) {
                            ForEach(budget.subBudgets, id: \.id) { subBudget in
                                Button {
                                    // Handle moving transaction into sub-budget here
                                    selectedSubBudget = subBudget
                                    showPopup = true
                                    
                                } label: {
                                    Text(subBudget.title)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 24)
                            }
                            
                            if budget.subBudgets.isEmpty {
                                Text("No sub-budgets under this budget")
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(.secondary)
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
            
         
            if showPopup {
                let subBudget = selectedSubBudget
                PopUpView(
                    title: "Move Transaction",
                    message: "Are you sure you want to move this transaction to \"\(subBudget?.title ?? "the selected sub-budget")\"?",
                    buttonTitle: "Confirm",
                    buttonAction: {
                        // Handle the actual move logic here
                        TransactionService.moveTransaction(transaction: transaction, to: subBudget!, context: context)
                        
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
