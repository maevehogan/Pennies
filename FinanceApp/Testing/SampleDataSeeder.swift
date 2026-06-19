//
//  SampleDataSeeder.swift
//  FinanceApp
//
//  This is used to populate the context upon app load so the data is viewable within the tab views
//  Created by Maeve Hogan on 5/9/26.
//
import SwiftData
import Foundation

enum SampleDataSeeder {
    static func reset(context: ModelContext) {
        // Delete all Budgets
        let budgetFetch = FetchDescriptor<Budget>()
        if let budgets = try? context.fetch(budgetFetch) {
            for budget in budgets {
                context.delete(budget)
            }
        }
        // Delete all SubBudgets
        let subBudgetFetch = FetchDescriptor<SubBudget>()
        if let subBudgets = try? context.fetch(subBudgetFetch) {
            for subBudget in subBudgets {
                context.delete(subBudget)
            }
        }
        // Delete all Transactions
        let transactionFetch = FetchDescriptor<Transaction>()
        if let transactions = try? context.fetch(transactionFetch) {
            for transaction in transactions {
                context.delete(transaction)
            }
        }
        try? context.save()
    }
    
    static func seed(context: ModelContext) {
        // Prevent duplicate inserts
        let budgetFetch = FetchDescriptor<Budget>()
        let transactionFetch = FetchDescriptor<Transaction>()
        let budgetsExist = (try? context.fetch(budgetFetch))?.isEmpty == false
        let transactionsExist = (try? context.fetch(transactionFetch))?.isEmpty == false
        if budgetsExist || transactionsExist {
            return
        }
        for budget in sampleBudgets {
            context.insert(budget)
        }
        try? context.save()
    }

}
