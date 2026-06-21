// CreateTransactionView.swift
// Sheet for manually creating a transaction.
//
// The user picks a destination budget, then optionally a named sub-budget
// (defaults to the main bucket if none is chosen), enters the merchant name,
// amount, and date, then taps Save.
//
// Flow:
//   1. Insert into SwiftData immediately so the UI updates without waiting
//   2. Push to the server via SyncService to get a serverId saved back locally
//
// The `close` callback is called on success or cancel to dismiss the sheet.

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

    // The visible budgets — excludes the hidden unassigned budget from the picker
    private var visibleBudgets: [Budget] {
        budgets.filter { $0.budgetName != unassignedBudgetName }
    }

    // The destination sub-budget:
    //   - Named sub-budget if the user picked one
    //   - Main bucket of the selected budget if no sub-budget chosen
    //   - Main bucket of the hidden unassigned budget if no budget chosen at all
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
                Color.black.ignoresSafeArea()

                Form {
                    // MARK: Budget picker
                    Section("Budget") {
                        Picker("Budget", selection: $selectedBudget) {
                            Text("No budget (unassigned)").tag(nil as Budget?)
                            ForEach(visibleBudgets) { budget in
                                Text(budget.budgetName).tag(budget as Budget?)
                            }
                        }
                        .onChange(of: selectedBudget) {
                            // Reset sub-budget selection when budget changes
                            selectedSubBudget = nil
                        }

                        // Only show sub-budget picker if the budget has named sub-budgets
                        if let budget = selectedBudget, !budget.namedSubBudgets.isEmpty {
                            Picker("Category", selection: $selectedSubBudget) {
                                Text("\(budget.budgetName) (general)").tag(nil as SubBudget?)
                                ForEach(budget.namedSubBudgets) { sub in
                                    Text(sub.title).tag(sub as SubBudget?)
                                }
                            }
                        }
                    }

                    // MARK: Transaction details
                    Section("Details") {
                        TextField("Merchant / description", text: $locationSpent)

                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $amountString)
                                .keyboardType(.decimalPad)
                        }

                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }

                    // Inline error if save fails
                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { close() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await save() }
                        }
                        .disabled(!canSave)
                    }
                }
            }
        }
    }

    // MARK: - Save

    private func save() async {
        guard let dest = destination else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        // Insert locally first so the UI updates immediately
        let tx = Transaction(location_spent: locationSpent.trimmingCharacters(in: .whitespaces), amount_spent: amount)
        tx.date = date
        dest.transactions.append(tx)
        context.insert(tx)

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save locally: \(error.localizedDescription)"
            return
        }

        // Push to the server and store the returned serverId
        let sync = SyncService(context: context)
        do {
            try await sync.createTransaction(
                locationSpent: tx.location_spent,
                amountSpent: tx.amount_spent,
                date: tx.date,
                in: dest,
                local: tx
            )
        } catch {
            // The transaction is already saved locally — it just won't have a serverId
            // until the next sync. Not a fatal error, but surface it for debugging.
            errorMessage = "Saved locally but server sync failed: \(error.localizedDescription)"
            return
        }

        close()
    }
}

#Preview {
    let container = try! ModelContainer(for: Budget.self, SubBudget.self, Transaction.self)
    SampleDataSeeder.seed(context: ModelContext(container))
    return CreateTransactionView(close: {})
        .modelContainer(container)
}
