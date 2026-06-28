// CreateTransactionView.swift
// FinanceApp

import SwiftUI
import SwiftData

struct CreateTransactionView: View {
    @Environment(\.modelContext) private var context
    @Query var budgets: [Budget]

    let close: () -> Void

    @State private var selectedBudget: Budget? = nil
    @State private var selectedSubBudget: SubBudget? = nil
    @State private var locationSpent: String = ""
    @State private var amountString: String = ""
    @State private var date: Date = Date()
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    private var amount: Double { Double(amountString) ?? 0 }

    private var visibleBudgets: [Budget] {
        budgets.filter { $0.budgetName != unassignedBudgetName }
    }

    private var destination: SubBudget? {
        if let sub = selectedSubBudget { return sub }
        if let budget = selectedBudget { return budget.mainSubBudget }
        return budgets.first(where: { $0.budgetName == unassignedBudgetName })?.mainSubBudget
    }

    private var canSave: Bool {
        !locationSpent.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                Form {
                    Section {
                        Picker("Budget", selection: $selectedBudget) {
                            Text("No budget (unassigned)").tag(nil as Budget?)
                            ForEach(visibleBudgets) { budget in
                                Text(budget.budgetName).tag(budget as Budget?)
                            }
                        }
                        .onChange(of: selectedBudget) { selectedSubBudget = nil }

                        if let budget = selectedBudget, !budget.namedSubBudgets.isEmpty {
                            Picker("Category", selection: $selectedSubBudget) {
                                Text("\(budget.budgetName) (general)").tag(nil as SubBudget?)
                                ForEach(budget.namedSubBudgets) { sub in
                                    Text(sub.title).tag(sub as SubBudget?)
                                }
                            }
                        }
                    } header: {
                        Text("Budget")
                            .foregroundStyle(Color.white.opacity(0.4))
                            .font(.caption.weight(.semibold))
                            .tracking(1)
                    }
                    .listRowBackground(Color.white.opacity(0.07))
                    .listRowSeparatorTint(Color.white.opacity(0.1))

                    Section {
                        TextField("Merchant / description", text: $locationSpent)
                            .foregroundStyle(.white)

                        HStack {
                            Text("$").foregroundStyle(Color.white.opacity(0.4))
                            TextField("0.00", text: $amountString)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(.white)
                        }

                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .foregroundStyle(.white)
                            .tint(Color.electricBlue)
                    } header: {
                        Text("Details")
                            .foregroundStyle(Color.white.opacity(0.4))
                            .font(.caption.weight(.semibold))
                            .tracking(1)
                    }
                    .listRowBackground(Color.white.opacity(0.07))
                    .listRowSeparatorTint(Color.white.opacity(0.1))

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                        .listRowBackground(Color.red.opacity(0.08))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { close() }
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView().tint(Color.electricBlue)
                    } else {
                        Button("Save") { Task { await save() } }
                            .foregroundStyle(canSave ? Color.electricBlue : Color.white.opacity(0.3))
                            .disabled(!canSave)
                    }
                }
            }
        }
        .presentationBackground { AppBackground() }
    }

    private func save() async {
        guard let dest = destination else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let tx = Transaction(location_spent: locationSpent.trimmingCharacters(in: .whitespaces), amount_spent: amount)
        tx.date = date
        dest.transactions.append(tx)
        context.insert(tx)

        do { try context.save() } catch {
            errorMessage = "Failed to save locally: \(error.localizedDescription)"
            return
        }

        let sync = SyncService(context: context)
        do {
            try await sync.createTransaction(locationSpent: tx.location_spent, amountSpent: tx.amount_spent, date: tx.date, in: dest, local: tx)
        } catch {
            errorMessage = "Saved locally but server sync failed: \(error.localizedDescription)"
            return
        }

        close()
    }
}

#Preview {
    let container = try! ModelContainer(for: Budget.self, SubBudget.self, Transaction.self)
    SampleDataSeeder.seed(context: ModelContext(container))
    return CreateTransactionView(close: {}).modelContainer(container)
}
