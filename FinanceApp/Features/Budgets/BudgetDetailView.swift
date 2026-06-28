//  BudgetDetailView.swift
//  FinanceApp

import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    let budget: Budget

    @State private var selectedSpendingIdx: Int? = nil
    @State private var openTransactionId: UUID? = nil

    var body: some View {
        ZStack(alignment: .center) {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    HStack(alignment: .center) {
                        GlowText(budget.budgetName, glowColors: [.electricBlue, .hotPink])

                        SubBudgetDropdown(
                            parentBudget: budget,
                            subBudgets: budget.subBudgets,
                            subBudgetIdx: $selectedSpendingIdx,
                            colors: appChartColors
                        )
                        .padding(.leading, 10)
                    }
                    .zIndex(100)

                    BudgetChartView(
                        parentBudget: .constant(budget),
                        idx: $selectedSpendingIdx,
                        chartColors: appChartColors,
                        chartLineWidth: 28,
                        diameter: 280
                    )

                    BudgetItemsListView(
                        spendings: .constant(budget.subBudgets),
                        idx: $selectedSpendingIdx,
                        openTransactionId: $openTransactionId,
                        chartColors: appChartColors
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                if openTransactionId != nil {
                    withAnimation(.spring(response: 0.3)) { openTransactionId = nil }
                }
            }
        )
    }
}

#Preview {
    BudgetDetailView(budget: sampleBudgets[0])
        .environment(AppRouter())
}
