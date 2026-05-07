// DummyData.swift
// FinanceApp
//
// Use this file for static sample data for previews and development before database integration.

import Foundation

let sampleTransactions: [Transaction] = [
    Transaction(location_spent: "Starbucks", amount_spent: 4.50),
    Transaction(location_spent: "Amazon", amount_spent: 23.99),
    Transaction(location_spent: "Grocery Store", amount_spent: 76.32),
    Transaction(location_spent: "Gas Station", amount_spent: 40.00),
    Transaction(location_spent: "Restaurant", amount_spent: 55.20),
    Transaction(location_spent: "Hydro Quebec", amount_spent: 15.00),
]


// Create sample sub-budgets
let spending1 = SubBudget(title: "Groceries", transactions: [sampleTransactions[0], sampleTransactions[2], sampleTransactions[4]])
let spending2 = SubBudget(title: "Entertainment", transactions: [sampleTransactions[1]])
let spending3 = SubBudget(title: "Transport", transactions: [sampleTransactions[3]])
let spending4 = SubBudget(title: "Rent", transactions: [])
let spending5 = SubBudget(title: "Utilities", transactions: [sampleTransactions[5]])

// MARK: - Sample Budgets
let sampleBudgets: [Budget] = [
    Budget(
        budgetName: "Monthly Budget",
        totalAmount: 1000.0,
        subBudgets: [
            spending1, spending2, spending3
        ]
    ),
    Budget(
        budgetName: "Rent Only",
        totalAmount: 1200.0,
        subBudgets: [
            spending2, spending4, spending5
        ]
    ),
    Budget(
        budgetName: "Simple Budget",
        totalAmount: 500.0
        // No subBudgets provided, will use default logic
    )
]

// Usage in previews:
// BudgetChartView(parentBudget: .constant(sampleBudgets[0]), ...)
// BudgetViewModel(spendings: sampleSpendings)
