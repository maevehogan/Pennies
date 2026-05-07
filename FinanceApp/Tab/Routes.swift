//
//  Routes.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import Foundation

enum HomeNavigation: Hashable {
    case budgetDetail(budget: Budget)
}

enum BudgetNavigation: Hashable {
    case budgetDetail(budget: Budget)
    //case createBudget
}

enum TransactionNavigation: Hashable {
    case transactionList
}

enum SettingsNavigation: Hashable {
    case settingsMain
}
