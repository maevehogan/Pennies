//
//  CreateBudgetView.swift
//  FinanceApp
//

import SwiftUI
import Foundation
import SwiftData

struct CreateBudgetView: View {
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                GradientLabel("Create a Budget", font: .title.bold())
                    .padding(.top, 20)
                CreateBudgetForm()
            }
        }
        .presentationBackground { AppBackground() }
    }
}

struct CreateBudgetForm: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router

    @State private var budgetName: String = ""
    @State private var amountString: String = ""
    @State private var isSaving = false

    private var totalAmount: Double { Double(amountString) ?? 0 }
    private var canSave: Bool { !budgetName.trimmingCharacters(in: .whitespaces).isEmpty && totalAmount > 0 }

    var body: some View {
        VStack(spacing: 32) {
            // Budget name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget Name")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(1.2)

                TextField("", text: $budgetName,
                    prompt: Text("e.g. Groceries, Rent…")
                        .foregroundColor(Color.white.opacity(0.3))
                )
                .foregroundStyle(.white)
                .font(.title3.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            budgetName.isEmpty
                                ? Color.white.opacity(0.1)
                                : Color.electricBlue.opacity(0.4),
                            lineWidth: 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: budgetName.isEmpty)
            }

            // Venmo-style amount input
            VStack(spacing: 8) {
                Text("Total Amount")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(1.2)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.4))

                    TextField("0", text: $amountString)
                        .keyboardType(.numberPad)
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .foregroundStyle(totalAmount > 0 ? Color.white : Color.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .fixedSize()
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.2), value: amountString)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    totalAmount > 0
                                        ? LinearGradient(colors: [Color.electricBlue.opacity(0.5), Color.hotPink.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 1.5
                                )
                        )
                )
                .animation(.easeInOut(duration: 0.25), value: totalAmount > 0)

                if totalAmount > 0 {
                    Text(totalAmount, format: .currency(code: "USD"))
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.35))
                        .transition(.opacity)
                }
            }

            // Save button — matches CreateSubBudgetView style
            Button {
                Task {
                    isSaving = true
                    defer { isSaving = false }

                    let newBudget = BudgetService.createBudget(
                        budgetName: budgetName.trimmingCharacters(in: .whitespaces),
                        totalAmount: totalAmount,
                        context: context
                    )
                    let sync = SyncService(context: context)
                    try? await sync.createBudget(name: budgetName, totalAmount: totalAmount, localBudget: newBudget)

                    budgetName = ""
                    amountString = ""
                    router.budgetsPath = []
                }
            } label: {
                Group {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Create Budget")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Group {
                        if canSave {
                            LinearGradient(colors: [.electricBlue, .neonPurple], startPoint: .leading, endPoint: .trailing)
                        } else {
                            Color.white.opacity(0.06)
                        }
                    }
                )
                .foregroundStyle(canSave ? Color.white : Color.white.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!canSave || isSaving)
            .animation(.easeInOut(duration: 0.2), value: canSave)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
    }
}

#Preview {
    let container = try! ModelContainer(for: Budget.self, SubBudget.self, Transaction.self)
    return CreateBudgetView()
        .modelContainer(container)
        .environment(AppRouter())
}
