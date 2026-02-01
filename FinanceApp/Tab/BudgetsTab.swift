//
//  BudgetTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/28/26.
//

import SwiftUI

struct BudgetsTab: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.budgetsPath) {
            BudgetPageView(
                navBudgetDetail: { budgetID in
                    router.selectedBudgetID = budgetID // Set selected budgetID
                    router.budgetsPath.append(BudgetNavigation.budgetDetail(budgetID: budgetID)) // Navigate to detail
                },
            )
            .navigationDestination(for: BudgetNavigation.self) { destination in
                switch destination {
                case .budgetDetail(let budgetID):
                    BudgetDetailView(budgetID: budgetID)
                }
            }
        }
    }
}

#Preview {
    BudgetsTab()
        .environment(AppRouter())
        .environment(BudgetsViewModel())
}
