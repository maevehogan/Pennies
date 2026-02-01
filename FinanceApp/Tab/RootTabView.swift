//
//  RootTabView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI
import Observation

struct RootTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        TabView(selection: tabSelection()) {
                HomeTab()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(TabItem.home)
                
                BudgetsTab()
                    .tabItem {
                        Label("Budgets", systemImage: "chart.pie")
                    }
                    .tag(TabItem.budgets)
                
                TransactionsTab()
                    .tabItem {
                        Label("Transactions", systemImage: "list.bullet")
                    }
                    .tag(TabItem.transactions)
                
                SettingsTab()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(TabItem.settings)
            }
    }
}


extension RootTabView {
    private func tabSelection() -> Binding<TabItem> {
        Binding {
            router.selectedTab
        } set: { newTab in
            if router.selectedTab == newTab {
                switch newTab {
                case .home:
                    router.homePath = []
                case .budgets:
                    router.budgetsPath = []
                case .transactions:
                    router.transactionsPath = []
                case .settings:
                    router.settingsPath = []
                }
            }
            router.selectedTab = newTab
        }
    }
}

#Preview {
    RootTabView()
        .environment(BudgetsViewModel())
        .environment(TransactionsViewModel())
        .environment(AppRouter())
}
