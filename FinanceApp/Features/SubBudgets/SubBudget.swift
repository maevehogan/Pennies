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
    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction] = []

    var amount: Double { transactions.reduce(0) { $0 + $1.amount_spent } }

    init(title: String, transactions: [Transaction] = []) {
        self.title = title
        self.transactions = transactions
    }
}
