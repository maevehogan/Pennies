//
//  BudgetViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/19/26.
//

import SwiftUI

@Observable
final class BudgetViewModel {
    var budgetID: UUID
    var selectedSpendingIdx: Int? = nil
    // No central store here; use Budget/Spendings static stores

    var budget: Budget? { Budget.allBudgets[budgetID] }
    var spendings: [Spendings] {
        budget?.subBudgetIDs.compactMap { Spendings.allSpendings[$0] } ?? []
    }

    init(budgetID: UUID, selectedSpendingIdx: Int? = nil) {
        self.budgetID = budgetID
        self.selectedSpendingIdx = selectedSpendingIdx
    }

    func addSpending(spending: Spendings) {
        let budget = budget
        budget?.addSubBudget(spending: spending)
        Spendings.allSpendings[spending.id] = spending
    }
    func deleteSpending(at index: Int) {
        let budget = budget
        let id = budget?.subBudgetIDs.remove(at: index)
        if let id = id {
            Spendings.allSpendings.removeValue(forKey: id)
        }
    }

    var setSelectedSpendingIdx: Binding<Int?> {
        Binding<Int?>(
            get: { self.selectedSpendingIdx },
            set: { newValue in self.selectedSpendingIdx = newValue }
        )
    }

    var getSelectedSpendingIdx: Int? {
        selectedSpendingIdx
    }
    
    func createNewBudget(budgetName: String, totalAmount: Double, subBudgets: [Spendings]) -> Budget {
        // instantiate the new budget object
        let newBudget = Budget(budgetName: budgetName, totalAmount: totalAmount)
        // add the sub-budgets (if there are any) to the new budget and update the central store
        for subBudget in subBudgets {
            newBudget.addSubBudget(spending: subBudget)
            Spendings.allSpendings[subBudget.id] = subBudget
        }
        // add the new budget to the central store
        Budget.allBudgets[newBudget.id] = newBudget
        return newBudget
    }
}
