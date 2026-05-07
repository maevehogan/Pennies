//
//  SpendingViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/31/26.
//

import SwiftUI
import Observation

@Observable
final class SubBudgetViewModel {
    var subBudget: SubBudget
    
    var transactions: [Transaction] {
        get {subBudget.transactions}
        set {subBudget.transactions = newValue}
    }
    
    init(subBudget: SubBudget) {
        self.subBudget = subBudget
    }
}
