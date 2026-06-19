//
//  HomeTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI
import Foundation

struct HomeTab: View {
    @Environment(AppRouter.self) private var router
    

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.homePath) {
            HomeView(
                navBudgetDetail: { budget in
                    router.selectedTab = .budgets
                    router.budgetsPath.append(.budgetDetail(budget: budget))
                },
                navTransactions: {
                    router.selectedTab = .transactions
                }
            )
            .navigationDestination(for: HomeNavigation.self) { destination in
                switch destination {
                case .createBudget:
                    CreateBudgetView()
                }
            }
        }
        
    }
}

#Preview {
    HomeTab()
        .environment(AppRouter())
}
