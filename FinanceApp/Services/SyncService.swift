// SyncService.swift
// Bridges the remote API and the local SwiftData cache.
//
// Strategy — upsert on serverId:
//   - Each SwiftData model has an optional `serverId` (the UUID the server assigned).
//   - On sync, we fetch the full state from the server, then for each record:
//       • If a local record with matching serverId exists → update its fields.
//       • If no match exists → insert a new local record with the serverId set.
//   - Local records with no serverId are ones created offline that haven't been
//     pushed yet — those are handled by the write methods (create, move, delete).
//
// Threading:
//   All methods are @MainActor because SwiftData's ModelContext is not thread-safe.
//   API calls are async and will suspend without blocking the main thread.
//
// Error handling:
//   Methods throw APIError. Callers should catch .unauthorized and redirect to login,
//   and surface other errors as an alert or inline message.

import Foundation
import SwiftData

@MainActor
struct SyncService {

    let context: ModelContext

    // MARK: - Pull (server → local cache)

    // Fetches all budgets from the server and upserts them into SwiftData.
    // Call this on app launch and on pull-to-refresh.
    func syncBudgets() async throws {
        let remote = try await BudgetAPI.getAll()
        for budgetResponse in remote {
            upsertBudget(budgetResponse)
        }
        try context.save()
    }

    // Fetches all transactions from the server and upserts them into SwiftData.
    // Useful for refreshing the flat Transactions tab without reloading all budgets.
    func syncTransactions() async throws {
        let remote = try await TransactionAPI.getAll()
        for txResponse in remote {
            upsertTransaction(txResponse)
        }
        try context.save()
    }

    // MARK: - Push (local → server) for Budgets

    // Creates a budget on the server, then saves the returned serverId locally.
    func createBudget(name: String, totalAmount: Double, localBudget: Budget) async throws {
        let response = try await BudgetAPI.create(name: name, totalAmount: totalAmount)
        localBudget.serverId = response.id

        // Assign serverIds to the sub-budgets the server created automatically
        for subResponse in response.subBudgets {
            if let localSub = localBudget.subBudgets.first(where: { $0.title == subResponse.title }) {
                localSub.serverId = subResponse.id
            }
        }
        try context.save()
    }

    // Updates a budget on the server. Requires the budget to have a serverId.
    func updateBudget(_ budget: Budget, name: String? = nil, totalAmount: Double? = nil) async throws {
        guard let serverId = budget.serverId else { return }
        let response = try await BudgetAPI.update(id: serverId, name: name, totalAmount: totalAmount)
        budget.budgetName = response.name
        budget.totalAmount = response.totalAmount
        try context.save()
    }

    // Deletes a budget on the server then removes it from SwiftData.
    func deleteBudget(_ budget: Budget) async throws {
        if let serverId = budget.serverId {
            try await BudgetAPI.delete(id: serverId)
        }
        // Delete locally regardless — if there's no serverId it was never synced
        context.delete(budget)
        try context.save()
    }

    // Adds a named sub-budget on the server and saves the returned serverId locally.
    func createSubBudget(title: String, under budget: Budget, localSub: SubBudget) async throws {
        guard let budgetServerId = budget.serverId else { return }
        let response = try await BudgetAPI.addSubBudget(budgetId: budgetServerId, title: title)
        localSub.serverId = response.id
        try context.save()
    }

    // Deletes a named sub-budget on the server then removes it locally.
    func deleteSubBudget(_ sub: SubBudget, under budget: Budget) async throws {
        if let budgetServerId = budget.serverId, let subServerId = sub.serverId {
            try await BudgetAPI.deleteSubBudget(budgetId: budgetServerId, subBudgetId: subServerId)
        }
        context.delete(sub)
        try context.save()
    }

    // MARK: - Push (local → server) for Transactions

    // Creates a transaction on the server and saves the returned serverId locally.
    // `targetSubBudget` must have a serverId (i.e. it has been synced at least once).
    func createTransaction(
        locationSpent: String,
        amountSpent: Double,
        date: Date = Date(),
        in subBudget: SubBudget,
        local: Transaction
    ) async throws {
        guard let subServerId = subBudget.serverId else { return }
        let response = try await TransactionAPI.create(
            subBudgetId: subServerId,
            locationSpent: locationSpent,
            amountSpent: amountSpent,
            date: date
        )
        local.serverId = response.id
        try context.save()
    }

    // Moves a transaction to a different sub-budget on the server, then updates locally.
    func moveTransaction(_ transaction: Transaction, to destination: SubBudget) async throws {
        guard let txServerId = transaction.serverId,
              let destServerId = destination.serverId else { return }
        _ = try await TransactionAPI.move(id: txServerId, toSubBudget: destServerId)
        try context.save()
    }

    // Deletes a transaction on the server then removes it locally.
    func deleteTransaction(_ transaction: Transaction) async throws {
        if let serverId = transaction.serverId {
            try await TransactionAPI.delete(id: serverId)
        }
        context.delete(transaction)
        try context.save()
    }

    // MARK: - Upsert helpers (used by pull sync)

    // Inserts or updates a Budget and its children from a server response.
    private func upsertBudget(_ response: BudgetResponse) {
        let budget = findOrCreate(Budget.self, serverId: response.id) {
            Budget(budgetName: response.name, totalAmount: response.totalAmount)
        }
        budget.serverId = response.id
        budget.budgetName = response.name
        budget.totalAmount = response.totalAmount

        for subResponse in response.subBudgets {
            upsertSubBudget(subResponse, under: budget)
        }
    }

    // Inserts or updates a SubBudget and its transactions from a server response.
    private func upsertSubBudget(_ response: SubBudgetResponse, under budget: Budget) {
        let sub = findOrCreate(SubBudget.self, serverId: response.id) {
            // Before creating a new sub-budget, check if Budget.init already created
            // a local placeholder with the same title and no serverId. Reuse it to
            // avoid ending up with duplicate sub-budgets (especially the main bucket).
            if let placeholder = budget.subBudgets.first(where: {
                $0.serverId == nil && $0.title == response.title
            }) {
                return placeholder
            }
            let s = SubBudget(title: response.title)
            budget.subBudgets.append(s)
            return s
        }
        sub.serverId = response.id
        sub.title = response.title

        for txResponse in response.transactions {
            upsertTransaction(txResponse, under: sub)
        }
    }

    // Inserts or updates a Transaction from a server response.
    // Always ensures the transaction is linked to its sub-budget, even for existing records.
    private func upsertTransaction(_ response: TransactionResponse, under sub: SubBudget? = nil) {
        let tx = findOrCreate(Transaction.self, serverId: response.id) {
            Transaction(location_spent: response.locationSpent, amount_spent: response.amountSpent)
        }
        tx.serverId = response.id
        tx.location_spent = response.locationSpent
        tx.amount_spent = response.amountSpent
        tx.date = response.date

        // Always re-link — handles both new records and existing ones that lost their relationship
        if let sub, !sub.transactions.contains(where: { $0.id == tx.id }) {
            sub.transactions.append(tx)
        }
    }

    // Looks up an existing SwiftData record by serverId, or creates a new one using the factory.
    private func findOrCreate<T>(
        _ type: T.Type,
        serverId: UUID,
        factory: () -> T
    ) -> T where T: PersistentModel, T: ServerSyncable {
        let descriptor = FetchDescriptor<T>()
        let all = (try? context.fetch(descriptor)) ?? []

        // SwiftData doesn't support filtering by arbitrary properties in a type-safe way
        // without knowing the key path, so we fetch all and filter in memory.
        // For large datasets consider adding an index on serverId.
        if let existing = all.first(where: { $0.serverId == serverId }) {
            return existing
        }
        let new = factory()
        context.insert(new)
        return new
    }
}

// Models that carry a server-assigned UUID used to match local cache entries to
// server records during sync.
protocol ServerSyncable {
    var serverId: UUID? { get set }
}

extension Budget: ServerSyncable {}
extension SubBudget: ServerSyncable {}
extension Transaction: ServerSyncable {}
