//
//  finance_appApp.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI
import SwiftData

@main
struct FinanceApp: App {
    @State private var budgetsVM = BudgetsViewModel()
    @State private var transactionsVM = TransactionsViewModel()
    @State private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(budgetsVM)
                .environment(transactionsVM)
                .environment(router)
            
        }
        .modelContainer(for: [
            Budget.self,
            SubBudget.self,
            Transaction.self,
        ])
    }
}
