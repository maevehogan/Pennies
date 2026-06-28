//
//  BudgetPageView.swift
//  FinanceApp
//

import SwiftUI
import Foundation
import SwiftData

struct BudgetPageView: View {
    let navBudgetDetail: (_ budget: Budget) -> Void

    @Environment(AppRouter.self) private var router

    @Query(filter: #Predicate<Budget> { $0.budgetName != "__unassigned__" })
    var budgets: [Budget]

    @State private var openBudgetId: UUID? = nil

    var body: some View {
        ZStack {
            AppBackground()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation { openBudgetId = nil }
                }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack {
                        GradientLabel("Budgets", font: .title.bold())
                        Spacer()
                        Button(action: { navCreateBudget(router: router) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.electricBlue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    VStack(spacing: 10) {
                        ForEach(budgets) { budget in
                            BudgetPageItem(
                                budget: budget,
                                openBudgetId: $openBudgetId
                            )
                            .onTapGesture { navBudgetDetail(budget) }
                            .padding(.horizontal, 20)
                        }

                        // Add budget placeholder row
                        Button(action: { navCreateBudget(router: router) }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.headline)
                                Text("Add Budget")
                                    .font(.headline)
                            }
                            .foregroundStyle(
                                LinearGradient(colors: [.electricBlue, .hotPink], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .glassCard(cornerRadius: 16, accent: .electricBlue)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    SampleDataSeeder.seed(context: ModelContext(container))

    return BudgetPageView(navBudgetDetail: { _ in })
        .modelContainer(container)
        .environment(AppRouter())
}
