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
