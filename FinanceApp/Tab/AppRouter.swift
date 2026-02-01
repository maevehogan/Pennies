//
//  AppRouter.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/30/26.
//

import SwiftUI
import Observation

@Observable
final class AppRouter {
    var selectedTab: TabItem = .home
    var homePath: [HomeNavigation] = []
    var budgetsPath: [BudgetNavigation] = []
    var transactionsPath: [TransactionNavigation] = []
    var settingsPath: [SettingsNavigation] = []
    var selectedBudgetID: UUID? = nil // Stores the currently selected budget
}
