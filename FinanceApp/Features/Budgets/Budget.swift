//
//  Budget.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import Foundation
import Observation

class Spendings: Identifiable, Equatable {
    let id = UUID()
    let parentBudgetID: UUID? = nil
    let title: String
    var transactionIDs: [UUID] = [] // Store transaction IDs instead of objects
    private var baseAmount: Double = 0.0
    
    // Central store for all sub-budgets (to be managed by your app/database)
    static var allSpendings: [UUID: Spendings] = [:]
    
    var transactions: [Transaction] {
        get { transactionIDs.compactMap { Transaction.allTransactions[$0] } }
        set { transactionIDs = newValue.map { $0.id }; newValue.forEach { Transaction.allTransactions[$0.id] = $0 } }
    }
    
    var amount: Double {
        get {
            if transactions.isEmpty {
                return baseAmount
            } else {
                return transactions.reduce(0) { $0 + $1.amount_spent }
            }
        }
        set {
            baseAmount = newValue
        }
    }
    
    init(title: String, amount: Double = 0.0, transactionIDs: [UUID] = []) {
        self.title = title
        self.baseAmount = amount
        self.transactionIDs = transactionIDs
    }
    
    static func == (lhs: Spendings, rhs: Spendings) -> Bool {
        return lhs.id == rhs.id
    }
}

@Observable
class Budget: Identifiable {
    let id = UUID()
    let budgetName: String
    let totalAmount: Double
    var subBudgetIDs: [UUID] = [] // Store sub-budget IDs instead of objects
    
    // Central store for all spendings (to be managed by your app/database)
    static var allBudgets: [UUID: Budget] = [:]
    
    var subBudgets: [Spendings] {
        get { subBudgetIDs.compactMap { Spendings.allSpendings[$0] } }
        set { subBudgetIDs = newValue.map { $0.id }; newValue.forEach { Spendings.allSpendings[$0.id] = $0 } }
    }
    
    var spentAmount: Double {
        subBudgets.reduce(0) { $0 + $1.amount }
    }
    
    init(budgetName: String, totalAmount: Double, subBudgetIDs: [UUID] = []) {
        self.budgetName = budgetName
        self.totalAmount = totalAmount
        self.subBudgetIDs = subBudgetIDs
    }
    
    func addSubBudget(spending: Spendings) {
        subBudgetIDs.append(spending.id)
        Spendings.allSpendings[spending.id] = spending
    }
}
