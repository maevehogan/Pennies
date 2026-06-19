//
//  BudgetViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/19/26.
//

import SwiftUI
import SwiftData

@Observable
final class BudgetViewModel {

    var selectedSpendingIdx: Int? = nil

    var selectedSpending: SubBudget? = nil
    
    // MARK: - Actions

    func addSubBudget(to budget: Budget, title: String, context: ModelContext) {
        let newSubBudget = SubBudget(title: title, transactions: [])
        budget.subBudgets.append(newSubBudget)
        context.insert(newSubBudget)
    }
    
    func deleteSubBudget(_ spending: SubBudget, from budget: Budget, context: ModelContext) {
            budget.subBudgets.removeAll { $0.id == spending.id }
            context.delete(spending)
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
    
}
