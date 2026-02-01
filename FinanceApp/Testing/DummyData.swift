
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

// Create sample spendings
let spending1 = Spendings(title: "Groceries", amount: 150.0)
let spending2 = Spendings(title: "Entertainment", amount: 75.0)
let spending3 = Spendings(title: "Transport", amount: 50.0)
let spending4 = Spendings(title: "Rent", amount: 350.0)
let spending5 = Spendings(title: "Utilities", amount: 100.0)

// MARK: - Sample Spendings
let sampleSpendings: [Spendings] = [
    spending1, spending2, spending3, spending4, spending5
]

// MARK: - Sample Budgets
let sampleBudgets: [Budget] = [
    Budget(
        budgetName: "Monthly Budget",
        totalAmount: 1000.0,
        subBudgetIDs: [
            spending1.id, spending2.id, spending3.id
        ]
    ),
    Budget(
        budgetName: "Rent Only",
        totalAmount: 1200.0,
        subBudgetIDs: [
            spending2.id, spending4.id, spending5.id
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
