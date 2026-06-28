//  HomeView.swift
//  FinanceApp

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router

    @Query(filter: #Predicate<Budget> { $0.budgetName != "__unassigned__" })
    var budgets: [Budget]

    let navBudgetDetail: (Budget) -> Void
    let navTransactions: () -> Void

    @State private var selectedBudgetIdx: Int = 0

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome Back")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.5))
                            GradientLabel("Dashboard", font: .title.bold())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    HomeChartsView(
                        navBudgetDetail: navBudgetDetail,
                        budgets: budgets,
                        router: router,
                        selectedBudgetIdx: $selectedBudgetIdx
                    )

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Button(action: navTransactions) {
                                Text("See All")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.electricBlue)
                            }
                        }
                        .padding(.horizontal, 20)

                        TransactionsListView(transactionPage: false, swipeEnabled: false)
                            .frame(height: 200)
                            .clipped()
                            .onTapGesture { navTransactions() }
                    }
                }
            }
            .safeAreaPadding(.bottom, 24)
        }
    }
}

// MARK: - Charts Carousel

struct HomeChartsView: View {
    let navBudgetDetail: (Budget) -> Void
    let budgets: [Budget]
    let router: AppRouter

    @Binding var selectedBudgetIdx: Int

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $selectedBudgetIdx) {
                ForEach(Array(budgets.enumerated()), id: \.element.id) { index, budget in
                    BudgetPage(budget: budget)
                        .contentShape(Rectangle())
                        .onTapGesture { navBudgetDetail(budget) }
                        .tag(index)
                        .padding(.horizontal, 20)
                }

                CreateBudgetPage(router: router)
                    .contentShape(Rectangle())
                    .onTapGesture { navCreateBudget(router: router) }
                    .tag(budgets.count)
                    .padding(.horizontal, 20)
            }
            .frame(height: 400)
            #if os(iOS) || os(tvOS) || os(watchOS)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            #else
            .tabViewStyle(DefaultTabViewStyle())
            #endif
        }
    }
}

// MARK: - Budget Card (Home Carousel)

struct BudgetPage: View {
    let budget: Budget

    var body: some View {
        VStack(spacing: 24) {
            GlowText(budget.budgetName, glowColors: [.electricBlue, .hotPink])

            BudgetChartView(
                parentBudget: .constant(budget),
                idx: .constant(nil),
                chartColors: appChartColors,
                chartLineWidth: 22,
                diameter: 240
            )
            .padding(.horizontal)
        }
        .padding(20)
    }
}

struct CreateBudgetPage: View {
    let router: AppRouter

    var body: some View {
        VStack(spacing: 24) {
            GlowText("New Budget", glowColors: [.hotPink, .electricBlue])

            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        LinearGradient(colors: [Color.hotPink.opacity(0.4), Color.electricBlue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)

                Button(action: { navCreateBudget(router: router) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(
                            LinearGradient(colors: [.electricBlue, .hotPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    HomeView(navBudgetDetail: { _ in }, navTransactions: {})
        .environment(AppRouter())
}
