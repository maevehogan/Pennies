//
//  BudgetListViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/26/26.
//

import SwiftUI
import Observation

@Observable
final class BudgetsViewModel {
    var budgetIDs: [UUID]
    static var allBudgets: [UUID: Budget] = [:]

    var budgets: [Budget] {
        get { budgetIDs.compactMap { Self.allBudgets[$0] } }
        set { budgetIDs = newValue.map { $0.id }; newValue.forEach { Self.allBudgets[$0.id] = $0 } }
    }

    init() {
        // Sample data for testing
        let groceries = Budget(budgetName: "Groceries", totalAmount: 1000)
        let rent = Budget(budgetName: "Rent", totalAmount: 1200)
        let entertainment = Budget(budgetName: "Entertainment", totalAmount: 500)
        // Add subBudgets
        let produce = Spendings(title: "Produce", amount: 400)
        let snacks = Spendings(title: "Snacks", amount: 350)
        let drinks = Spendings(title: "Drinks", amount: 100)
        groceries.subBudgets = [produce, snacks, drinks]
        let movies = Spendings(title: "Movies", amount: 200)
        let games = Spendings(title: "Games", amount: 150)
        let concerts = Spendings(title: "Concerts", amount: 100)
        entertainment.subBudgets = [movies, games, concerts]
        // Populate central store
        Self.allBudgets = [groceries.id: groceries, rent.id: rent, entertainment.id: entertainment]
        budgetIDs = [groceries.id, rent.id, entertainment.id]
    }

    func loadBudgets() {
        // implement this later with loading from DB
        let groceries = Budget(budgetName: "Groceries", totalAmount: 300)
        let rent = Budget(budgetName: "Rent", totalAmount: 1200)
        let entertainment = Budget(budgetName: "Entertainment", totalAmount: 150)
        Self.allBudgets = [groceries.id: groceries, rent.id: rent, entertainment.id: entertainment]
        budgetIDs = [groceries.id, rent.id, entertainment.id]
    }
}
