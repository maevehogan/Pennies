//
//  Transaction.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import Foundation

class Transaction: Identifiable {
    let id = UUID()
    
    let location_spent: String
    let amount_spent: Double
    let date: Date
    
    // Central store for all transactions (to be managed by your app/database)
    static var allTransactions: [UUID: Transaction] = [:]
    
    init(location_spent: String, amount_spent: Double) {
        self.location_spent = location_spent
        self.amount_spent = amount_spent
        self.date = Date()
    }
    
}
