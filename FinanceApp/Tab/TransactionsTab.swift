//
//  TransactionsTab.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/28/26.
//

import SwiftUI

struct TransactionsTab: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.transactionsPath) {
            TransactionsListView()
                .navigationDestination(for: TransactionNavigation.self) { destination in
                    switch destination {
                    case .transactionList:
                        TransactionsListView()
                        
                    }
                }
        }

    }
}


#Preview {
    TransactionsTab()
        .environment(AppRouter())
}
