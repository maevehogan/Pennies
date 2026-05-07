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
//    var transactionIDs: [UUID]
//    static var allTransactions: [UUID: Transaction] = [:]
//
//    var transactions: [Transaction] {
//        get { transactionIDs.compactMap { Self.allTransactions[$0] } }
//        set { transactionIDs = newValue.map { $0.id }; newValue.forEach { Self.allTransactions[$0.id] = $0 } }
//    }
//
//    init() {
//        // Sample data for testing
//        let t1 = Transaction(location_spent: "Starbucks", amount_spent: 4.50)
//        let t2 = Transaction(location_spent: "Amazon", amount_spent: 23.99)
//        let t3 = Transaction(location_spent: "Grocery Store", amount_spent: 76.32)
//        let t4 = Transaction(location_spent: "Gas Station", amount_spent: 40.00)
//        Self.allTransactions = [t1.id: t1, t2.id: t2, t3.id: t3, t4.id: t4]
//        transactionIDs = [t1.id, t2.id, t3.id, t4.id]
//    }
//
//    func addTransaction(location: String, amount: Double) {
//        let newTransaction = Transaction(location_spent: location, amount_spent: amount)
//        transactionIDs.append(newTransaction.id)
//        Self.allTransactions[newTransaction.id] = newTransaction
//    }
//
//    func deleteTransaction(transaction: Transaction) {
//        transactionIDs.removeAll { $0 == transaction.id }
//        Self.allTransactions.removeValue(forKey: transaction.id)
//    }
}
