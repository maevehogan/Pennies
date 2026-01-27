//
//  BudgetListViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/26/26.
//

import SwiftUI
import Observation

@Observable
class BudgetsViewModel {
    var budgets: [Budget]
    
    init() {
        // Sample data for testing
        self.budgets = [Budget(budgetName: "Groceries", totalAmount: 300),
                        Budget(budgetName: "Rent", totalAmount: 1200),
                        Budget(budgetName: "Entertainment", totalAmount: 150)]
    }
    
    func loadBudgets() {
        // implement this later with loading from DB
        budgets = [
            Budget(budgetName: "Groceries", totalAmount: 300),
            Budget(budgetName: "Rent", totalAmount: 1200),
            Budget(budgetName: "Entertainment", totalAmount: 150)
        ]
    }
    
}

