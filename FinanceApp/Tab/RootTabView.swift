//
//  RootTabView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/27/26.
//

import SwiftUI
import Observation
import SwiftData

struct RootTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    let onLogout: (ModelContext) -> Void

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

                SettingsTab(onLogout: { onLogout(context) })
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(TabItem.settings)
            }
            .task {
                let sync = SyncService(context: context)
                try? await sync.syncBudgets()
                await BudgetService.ensureUnassignedBudget(context: context)
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
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    let context = ModelContext(container)
    // Reset and seed the preview container
    SampleDataSeeder.reset(context: context)
    SampleDataSeeder.seed(context: context)
    
    return RootTabView(onLogout: { _ in })
        .environment(AppRouter())
        .modelContainer(container)
}
