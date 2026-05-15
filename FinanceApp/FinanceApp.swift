//
//  finance_appApp.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct FinanceApp: App {
    
    @State private var router = AppRouter()
    
    static let sharedModelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for:
                Budget.self,
                SubBudget.self,
                Transaction.self
            )
            
            SampleDataSeeder.seed(context: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(router)
            
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
