//
//  BudgetService.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/9/26.
//

import Foundation
import SwiftData

// The internal name used to identify the hidden catch-all budget.
// Never shown to the user — used only for lookups.
let unassignedBudgetName = "__unassigned__"

struct BudgetService {

    // Returns the hidden "Unassigned" budget, creating it if it doesn't exist.
    // This budget holds transactions the user hasn't assigned to a real budget yet.
    // It is excluded from BudgetPageView and all budget totals.
    @discardableResult
    static func ensureUnassignedBudget(context: ModelContext) -> Budget {
        let descriptor = FetchDescriptor<Budget>()
        let all = (try? context.fetch(descriptor)) ?? []
        if let existing = all.first(where: { $0.budgetName == unassignedBudgetName }) {
            return existing
        }
        let budget = Budget(budgetName: unassignedBudgetName, totalAmount: 0)
        context.insert(budget)
        try? context.save()
        return budget
    }

    static func createBudget(budgetName: String, totalAmount: Double, context: ModelContext) -> Budget {
        let newBudget = Budget(budgetName: budgetName, totalAmount: totalAmount)
        
        // persist the new budget
        context.insert(newBudget)
        
        do {
            try context.save()
            print("saved successfully")
        } catch {
            print("save failed:", error)
        }
        
        return newBudget
    }
    
    static func updateBudget(budget: Budget, newName: String?, newAmount: Double?, context: ModelContext) {
        if let newName = newName {
            budget.budgetName = newName
        }
        if let newAmount = newAmount {
            budget.totalAmount = newAmount
        }
        
        try? context.save()
    }
    
    static func deleteBudget(budget: Budget, context: ModelContext) {
        context.delete(budget)
    }


}
