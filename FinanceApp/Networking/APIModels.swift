// APIModels.swift
// Codable structs that mirror the server's response DTOs.
// These are separate from the SwiftData @Model classes — they represent
// what comes over the wire and get mapped into SwiftData models by SyncService.
//
// Naming convention: server DTOs end in "Response" or "Request" to distinguish
// them from the local SwiftData models (Budget, SubBudget, Transaction).

import Foundation

// MARK: - Auth

struct TokenResponse: Decodable {
    let token: String
}

// MARK: - Budgets

struct BudgetResponse: Decodable {
    let id: UUID
    let name: String
    let totalAmount: Double
    let spentAmount: Double
    let subBudgets: [SubBudgetResponse]
}

struct SubBudgetResponse: Decodable {
    let id: UUID
    let title: String
    // True when this is the implicit main bucket (title == "")
    let isMain: Bool
    let spentAmount: Double
    let transactions: [TransactionResponse]
}

// MARK: - Transactions

struct TransactionResponse: Decodable {
    let id: UUID
    let subBudgetId: UUID
    let locationSpent: String
    let amountSpent: Double
    let date: Date
    // "manual" or "plaid"
    let source: String
    // Institution name (e.g. "Chase") for Plaid-imported transactions; nil for manual
    let institutionName: String?
}

// MARK: - Request bodies (sent to the server)

struct CreateBudgetRequest: Encodable {
    let name: String
    let totalAmount: Double
}

struct UpdateBudgetRequest: Encodable {
    let name: String?
    let totalAmount: Double?
}

struct CreateSubBudgetRequest: Encodable {
    let title: String
}

struct CreateTransactionRequest: Encodable {
    let subBudgetId: UUID
    let locationSpent: String
    let amountSpent: Double
    let date: Date?
}

struct UpdateTransactionRequest: Encodable {
    let subBudgetId: UUID?
    let locationSpent: String?
    let amountSpent: Double?
    let date: Date?
}

// MARK: - Plaid

struct LinkedAccount: Decodable, Identifiable {
    let id: UUID
    let institutionName: String
}
