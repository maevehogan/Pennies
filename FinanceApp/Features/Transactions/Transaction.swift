//
//  Transaction.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    var id: UUID = UUID()

    // The UUID assigned by the server. Nil until this transaction has been synced.
    var serverId: UUID?

    var location_spent: String
    var amount_spent: Double
    var date: Date

    init(location_spent: String, amount_spent: Double) {
        self.location_spent = location_spent
        self.amount_spent = amount_spent
        self.date = Date()
    }
    
}
