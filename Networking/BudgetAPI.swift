// BudgetAPI.swift
// Networking calls for the Budget and SubBudget resources.
//
// These methods return raw API response types (BudgetResponse, SubBudgetResponse).
// SyncService is responsible for mapping those into SwiftData models
// and saving them to the local cache.
//
// All methods throw APIError — callers should handle .unauthorized by redirecting to login.

import Foundation

struct BudgetAPI {

    // Fetches all budgets for the logged-in user, including sub-budgets and transactions.
    static func getAll() async throws -> [BudgetResponse] {
        try await APIClient.shared.get([BudgetResponse].self, from: "/budgets")
    }

    // Fetches a single budget by ID with full sub-budget and transaction detail.
    static func get(id: UUID) async throws -> BudgetResponse {
        try await APIClient.shared.get(BudgetResponse.self, from: "/budgets/\(id)")
    }

    // Creates a new budget. The server automatically creates the main sub-budget.
    static func create(name: String, totalAmount: Double) async throws -> BudgetResponse {
        let body = CreateBudgetRequest(name: name, totalAmount: totalAmount)
        return try await APIClient.shared.post(BudgetResponse.self, to: "/budgets", body: body)
    }

    // Updates a budget's name and/or total amount. Pass nil for fields that should not change.
    static func update(id: UUID, name: String? = nil, totalAmount: Double? = nil) async throws -> BudgetResponse {
        let body = UpdateBudgetRequest(name: name, totalAmount: totalAmount)
        return try await APIClient.shared.put(BudgetResponse.self, to: "/budgets/\(id)", body: body)
    }

    // Deletes a budget and all its sub-budgets and transactions.
    static func delete(id: UUID) async throws {
        try await APIClient.shared.delete(path: "/budgets/\(id)")
    }

    // Adds a named sub-budget to an existing budget.
    // The main (empty-title) sub-budget is created automatically — don't call this for it.
    static func addSubBudget(budgetId: UUID, title: String) async throws -> SubBudgetResponse {
        let body = CreateSubBudgetRequest(title: title)
        return try await APIClient.shared.post(
            SubBudgetResponse.self,
            to: "/budgets/\(budgetId)/sub-budgets",
            body: body
        )
    }

    // Deletes a named sub-budget and all its transactions.
    // The server will reject attempts to delete the main (empty-title) sub-budget.
    static func deleteSubBudget(budgetId: UUID, subBudgetId: UUID) async throws {
        try await APIClient.shared.delete(path: "/budgets/\(budgetId)/sub-budgets/\(subBudgetId)")
    }
}
