//
//  finance_appApp.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI

@main
struct FinanceApp: App {
    @State private var router = NavRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .home:
                            HomeView()
                        case .budgetDetail:
                            BudgetDetailView()
                        case .budgets:
                            BudgetDetailView()
                        }
                    }
            }
            .environment(router)
        }
    }
}
