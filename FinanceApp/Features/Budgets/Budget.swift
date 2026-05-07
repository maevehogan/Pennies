//
//  Budget.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import Foundation
import SwiftData

@Model
class Budget: Identifiable {
    
    var budgetName: String
    var totalAmount: Double
    
    @Relationship(deleteRule: .cascade)
    var subBudgets: [SubBudget] = []
    
    var spentAmount: Double {
        subBudgets.reduce(0) { $0 + $1.amount }
    }
    
    init(budgetName: String, totalAmount: Double, subBudgets: [SubBudget] = []) {
        self.budgetName = budgetName
        self.totalAmount = totalAmount
        
        if subBudgets.isEmpty {
            // Create default sub-budget with title ""
            let defaultSubBudget = SubBudget(title: "")
            self.subBudgets = [defaultSubBudget]
        } else {
            self.subBudgets = subBudgets
        }
    }
    
    func addSubBudget(subBudget: SubBudget) {
        subBudgets.append(subBudget)
    }
}
