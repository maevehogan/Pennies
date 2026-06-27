// TransactionAPI.swift
// Networking calls for the Transaction resource.
//
// The flat GET /transactions endpoint returns all transactions for the logged-in user
// across all budgets — this powers the Transactions tab.
//
// Moving a transaction to a different sub-budget is done via update(id:subBudgetId:),
// which sends PUT /transactions/:id with the new subBudgetId. The server validates
// that the destination sub-budget belongs to the same user.

import Foundation

struct TransactionAPI {

    // Fetches all transactions for the logged-in user, sorted newest first.
    static func getAll() async throws -> [TransactionResponse] {
        try await APIClient.shared.get([TransactionResponse].self, from: "/transactions")
    }

    // Manually creates a transaction in the given sub-budget.
    // Pass nil for date to default to the current time on the server.
    static func create(
        subBudgetId: UUID,
        locationSpent: String,
        amountSpent: Double,
        date: Date? = nil
    ) async throws -> TransactionResponse {
        let body = CreateTransactionRequest(
            subBudgetId: subBudgetId,
            locationSpent: locationSpent,
            amountSpent: amountSpent,
            date: date
        )
        return try await APIClient.shared.post(TransactionResponse.self, to: "/transactions", body: body)
    }

    // Updates one or more fields on an existing transaction.
    // Pass nil for fields that should not change.
    // Passing a new subBudgetId moves the transaction to a different budget.
    static func update(
        id: UUID,
        subBudgetId: UUID? = nil,
        locationSpent: String? = nil,
        amountSpent: Double? = nil,
        date: Date? = nil
    ) async throws -> TransactionResponse {
        let body = UpdateTransactionRequest(
            subBudgetId: subBudgetId,
            locationSpent: locationSpent,
            amountSpent: amountSpent,
            date: date
        )
        return try await APIClient.shared.put(TransactionResponse.self, to: "/transactions/\(id)", body: body)
    }

    // Moves a transaction to a different sub-budget.
    // Convenience wrapper around update() for the "move transaction" flow.
    static func move(id: UUID, toSubBudget subBudgetId: UUID) async throws -> TransactionResponse {
        try await update(id: id, subBudgetId: subBudgetId)
    }

    // Deletes a transaction permanently.
    static func delete(id: UUID) async throws {
        try await APIClient.shared.delete(path: "/transactions/\(id)")
    }
}
