//
//  NavigationMethods.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 2/1/26.
//

import Foundation
import SwiftUI

func navBudgetDetail(router: AppRouter, budget: Budget) {
    // Switch to Budgets tab
    router.selectedTab = .budgets
    // Set the selected budget
    router.selectedBudget = budget
    
    router.budgetsPath.append(.budgetDetail(budget: budget))
}

func navCreateBudget(router: AppRouter) {
    router.selectedTab = .budgets
    router.budgetsPath.append(.createBudget)
}

func navAddSubBudget(router: AppRouter, parentBudget: Budget) {
    // Should already be on the budgets tab
    // Set the selected budget to the parent of the sub-budget being created
    router.selectedBudget = parentBudget
    router.budgetsPath.append(.createSubBudget(parentBudget: parentBudget))
}


func navBack(router: AppRouter) {

    switch router.selectedTab {

        case .home:
            if !router.homePath.isEmpty {
                router.homePath.removeLast()
            }

        case .budgets:
            if !router.budgetsPath.isEmpty {
                router.budgetsPath.removeLast()
            }

        case .transactions:
            if !router.transactionsPath.isEmpty {
                router.transactionsPath.removeLast()
            }

        case .settings:
            if !router.settingsPath.isEmpty {
                router.settingsPath.removeLast()
            }
        }
}
