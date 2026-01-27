//
//  NavRouter.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/18/26.
//

import SwiftUI
import Observation

// This router is meant to handle all the routes in one place to centralize navigation logic
// and avoid passing navigation states through multiple views and/or duplicating logic in
// multiple places.

@Observable
@MainActor
class NavRouter {
    var path = NavigationPath()
    
    func navHome() {
        path = NavigationPath()
        path.append(Route.home)
    }
    
    func navBudgets() {
        path.append(Route.budgets)
    }
    
    func navBudgetDetail() {
        path.append(Route.budgetDetail)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
