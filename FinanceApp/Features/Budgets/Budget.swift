//
//  Budget.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import Foundation
import SwiftData

@Model
class Budget {
    var id = UUID()

    // The UUID assigned by the server. Nil until this budget has been synced.
    // Used by SyncService to match local records to server records on subsequent syncs.
    var serverId: UUID?

    var budgetName: String
    var totalAmount: Double
    
    @Relationship(deleteRule: .cascade)
    var subBudgets: [SubBudget] = []
    
    var spentAmount: Double {
        subBudgets.reduce(0) { $0 + $1.amount }
    }

    // The default bucket used when a transaction is assigned to the budget
    // itself rather than to a user-named sub-budget. Identified by an empty title.
    var mainSubBudget: SubBudget? {
        subBudgets.first(where: { $0.title.isEmpty })
    }

    // Sub-budgets the user has explicitly named (excludes the main bucket).
    var namedSubBudgets: [SubBudget] {
        subBudgets.filter { !$0.title.isEmpty }
    }

    init(budgetName: String, totalAmount: Double, subBudgets: [SubBudget] = []) {
        self.budgetName = budgetName
        self.totalAmount = totalAmount
        var all = subBudgets
        if !all.contains(where: { $0.title.isEmpty }) {
            all.append(SubBudget(title: ""))
        }
        self.subBudgets = all
    }

    func addSubBudget(subBudget: SubBudget) {
        subBudgets.append(subBudget)
    }
}
