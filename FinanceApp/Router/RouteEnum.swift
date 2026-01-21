//
//  RouteEnum.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/18/26.
//
import SwiftUI

enum Route: Hashable {
    case home
    case budgets
    case budgetDetail  // Removed budgetID for simplicity in testing
    //case budgetDetail(budgetID: UUID)
}
