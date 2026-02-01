//
//  Routes.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import Foundation

enum HomeNavigation: Hashable {
    case budgetDetail(budgetID: UUID)
}

enum BudgetNavigation: Hashable {
    case budgetDetail(budgetID: UUID)
    //case createBudget
}

enum TransactionNavigation: Hashable {
    case transactionList
}

enum SettingsNavigation: Hashable {
    case settingsMain
}
