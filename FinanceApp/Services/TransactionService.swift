//
//  TransactionService.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/22/26.
//

import Foundation
import SwiftData

struct TransactionService {
    
    static func unassignTransaction(transaction: Transaction, context: ModelContext) {
        let allSubBudgets = (try? context.fetch(FetchDescriptor<SubBudget>())) ?? []
        for sb in allSubBudgets {
            sb.transactions.removeAll { $0.id == transaction.id }
        }
        do {
            try context.save()
        } catch {
            print("unassignTransaction save failed:", error)
        }
    }

    static func moveTransaction(transaction: Transaction, to subBudget: SubBudget, context: ModelContext) {
        // Remove from whichever sub-budget currently owns this transaction
        let allSubBudgets = (try? context.fetch(FetchDescriptor<SubBudget>())) ?? []
        for sb in allSubBudgets {
            sb.transactions.removeAll { $0.id == transaction.id }
        }

        subBudget.transactions.append(transaction)

        do {
            try context.save()
        } catch {
            print("moveTransaction save failed:", error)
        }
    }
}
