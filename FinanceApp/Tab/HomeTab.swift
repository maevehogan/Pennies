//
//  HomeTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI

struct HomeTab: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.homePath) {
            HomeView(
                navBudgetDetail: { budgetID in
                    router.selectedBudgetID = budgetID
                    router.selectedTab = .budgets
                    router.budgetsPath.append(.budgetDetail(budgetID: budgetID))
                },
                navTransactions: {
                    router.selectedTab = .transactions
                }
            )
            .navigationDestination(for: HomeNavigation.self) { destination in
                switch destination {
                case .budgetDetail(let budgetID):
                    BudgetDetailView(budgetID: budgetID)
                
                }
            }
        }
    }
}

#Preview {
    HomeTab()
        .environment(AppRouter())
        .environment(BudgetsViewModel())
        .environment(TransactionsViewModel())
}
