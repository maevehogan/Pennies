//
//  BudgetViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/19/26.
//

import SwiftUI

@Observable
final class BudgetViewModel {
    var spendings: [Spendings] = []
    var selectedSpendingIdx: Int? = nil
    
    init(
        // some dummy data for preview purposes
        spendings: [Spendings] = [
            .init(title: "Groceries", amount: 0.45),
            .init(title: "Rent", amount: 0.35),
            .init(title: "Utilities", amount: 0.10),
            .init(title: "Transport", amount: 0.05),
            .init(title: "Entertainment", amount: 0.05)
        ],
        selectedSpendingIdx: Int? = nil) {
        self.spendings = spendings
        self.selectedSpendingIdx = selectedSpendingIdx
    }
    
}
