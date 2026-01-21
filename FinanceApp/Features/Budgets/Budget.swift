//
//  Budget.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import Foundation

class Spendings: Identifiable, Equatable {
    let id = UUID()
    let parentBudgetID: UUID? = nil
    let title: String
    let amount: Double
    
    init(title: String, amount: Double) {
        self.title = title
        self.amount = amount
    }
    
    static func == (lhs: Spendings, rhs: Spendings) -> Bool {
        return lhs.id == rhs.id
    }
}

class Budget: Identifiable {
    let id = UUID()
    let budgetName: String
    let totalAmount: Double
    var subBudgets: [Spendings] = []
    
    init(budgetName: String, totalAmount: Double) {
        self.budgetName = budgetName
        self.totalAmount = totalAmount
    }
    
    func addSubBudget(spending: Spendings) {
        subBudgets.append(spending)
    }
}

