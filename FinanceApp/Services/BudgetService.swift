//
//  BudgetService.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/9/26.
//

import Foundation
import SwiftData

struct BudgetService {
    
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
