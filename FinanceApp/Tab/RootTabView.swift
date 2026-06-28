//
//  RootTabView.swift
//  FinanceApp
//

import SwiftUI
import Observation
import SwiftData

struct RootTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    let onLogout: (ModelContext) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // All tabs kept alive via opacity so NavigationStack state persists
            ZStack {
                HomeTab()
                    .opacity(router.selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(router.selectedTab == .home)

                BudgetsTab()
                    .opacity(router.selectedTab == .budgets ? 1 : 0)
                    .allowsHitTesting(router.selectedTab == .budgets)

                TransactionsTab()
                    .opacity(router.selectedTab == .transactions ? 1 : 0)
                    .allowsHitTesting(router.selectedTab == .transactions)

                SettingsTab(onLogout: { onLogout(context) })
                    .opacity(router.selectedTab == .settings ? 1 : 0)
                    .allowsHitTesting(router.selectedTab == .settings)
            }

            FloatingTabBar()
        }
        .task {
            let sync = SyncService(context: context)
            try? await sync.syncBudgets()
            await BudgetService.ensureUnassignedBudget(context: context)
        }
    }
}

// MARK: - Floating Tab Bar

private struct FloatingTabBar: View {
    @Environment(AppRouter.self) private var router

    private let tabs: [(item: TabItem, icon: String, label: String)] = [
        (.home,         "house.fill",         "Home"),
        (.budgets,      "chart.pie.fill",      "Budgets"),
        (.transactions, "list.bullet",         "Transactions"),
        (.settings,     "gearshape.fill",      "Settings"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.item) { tab in
                TabBarButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: router.selectedTab == tab.item
                ) {
                    if router.selectedTab == tab.item {
                        // Tap active tab → pop to root
                        switch tab.item {
                        case .home:         router.homePath = []
                        case .budgets:      router.budgetsPath = []
                        case .transactions: router.transactionsPath = []
                        case .settings:     router.settingsPath = []
                        }
                    } else {
                        router.selectedTab = tab.item
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.14).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .shadow(color: Color.black.opacity(0.6), radius: 16, y: 4)
    }
}

private struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(
                isSelected
                    ? LinearGradient(colors: [.electricBlue, .hotPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.4)], startPoint: .top, endPoint: .bottom)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.electricBlue.opacity(0.12))
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}


#Preview {
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    let context = ModelContext(container)
    SampleDataSeeder.reset(context: context)
    SampleDataSeeder.seed(context: context)

    return RootTabView(onLogout: { _ in })
        .environment(AppRouter())
        .modelContainer(container)
        .environment(UserSession())
}
