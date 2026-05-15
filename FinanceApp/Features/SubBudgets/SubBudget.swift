//
//  SubBudget.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/6/26.
//

import Foundation
import SwiftData

@Model
class SubBudget {

    var title: String = ""
    var amount: Double
    var transactions: [Transaction] = []
    
    init(title: String, transactions: [Transaction] = []) {
        self.title = title
        self.transactions = transactions
        self.amount = transactions.reduce(0) { $0 + $1.amount_spent }
    }
}
