//
//  Routes.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

enum HomeNavigation: Hashable{
    case budgetDetail
    //case createBudget
    case transactions
}

enum BudgetRoute {
    case budgetList
    case budgetDetail
    case createBudget
}

enum TransactionRoute {
    case transactionList
}

enum SettingsRoute {
    case settingsMain
}
