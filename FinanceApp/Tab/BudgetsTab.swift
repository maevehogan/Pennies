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
                navBudgetDetail: { budget in
                    router.selectedBudget = budget // Set selected budget
                    router.budgetsPath.append(BudgetNavigation.budgetDetail(budget: budget)) // Navigate to detail
                },
            )
            .navigationDestination(for: BudgetNavigation.self) { destination in
                switch destination {
                
                case .budgetDetail(let budget):
                    BudgetDetailView(budget: budget)
                }
            }
        }
    }
}

#Preview {
    BudgetsTab()
        .environment(AppRouter())
}
