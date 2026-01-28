//
//  HomeTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI

struct HomeTab: View {
    @Binding var path: [HomeNavigation]

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                navBudgetDetail: {
                    path.append(.budgetDetail)
                },
                
            )
                .navigationDestination(for: HomeNavigation.self) { destination in
                    switch destination {
                    case .budgetDetail:
                        BudgetDetailView()
                    case .transactions:
                        TransactionsListView()
                    }
                }
        }
    }
}


#Preview {
    HomeTab(path: .constant([]))
}
