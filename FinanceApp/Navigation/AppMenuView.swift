//
//  AppMenuView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import SwiftUI

struct AppMenuView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            
            TabSection {
                Tab("Budgets", systemImage: "chart.pie") {
                    BudgetDetailView()
                }
            }
            
            Tab("Transactions", systemImage: "clock") {
                TransactionsListView()
            }
            
            Tab("Settings", systemImage: "gearshape") {
                EmptyView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    AppMenuView()
        .environment(NavRouter())
        .environment(BudgetViewModel())
    
}
