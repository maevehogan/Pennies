//
//  TransactionsViewModel.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/26/26.
//

import SwiftUI
import Observation

@Observable
class TransactionsViewModel {
    // Properties and methods for managing transactions will go here
    var transactions: [Transaction]
    
    init() {
        // Sample data for testing
        self.transactions = [
            .init(location_spent: "Starbucks", amount_spent: 4.50),
            .init(location_spent: "Amazon", amount_spent: 23.99),
            .init(location_spent: "Grocery Store", amount_spent: 76.32),
            .init(location_spent: "Gas Station", amount_spent: 40.00)
        ]
    }
    
    func addTransaction(location: String, amount: Double) {
        let newTransaction = Transaction(location_spent: location, amount_spent: amount)
        transactions.append(newTransaction)
    }
    
    func deleteTransaction(transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }
}
