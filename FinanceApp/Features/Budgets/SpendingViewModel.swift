//
//  SpendingViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/31/26.
//

import SwiftUI
import Observation

@Observable
final class SpendingViewModel {
    var spending: Spendings
    
    var transactions: [Transaction] {
        get {spending.transactions}
        set {spending.transactions = newValue}
    }
    
    init(spending: Spendings) {
        self.spending = spending
    }
}
