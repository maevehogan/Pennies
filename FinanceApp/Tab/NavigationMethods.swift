//
//  NavigationMethods.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 2/1/26.
//

import Foundation
import SwiftUI

func navBudgetDetail(router: AppRouter, budgetID: UUID) {
    // Switch to Budgets tab
    router.selectedTab = .budgets
    // Set the selected budget ID
    router.selectedBudgetID = budgetID
    
    router.budgetsPath.append(.budgetDetail(budgetID: budgetID))
}
