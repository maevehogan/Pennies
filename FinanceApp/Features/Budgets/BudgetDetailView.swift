//  BudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    let budget: Budget
    
    @State private var selectedSpendingIdx: Int? = nil
    
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 50) {
                Text("\(budget.budgetName)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                BudgetChartView(
                    parentBudget:
                            .constant(budget),
                    idx: $selectedSpendingIdx,
                    chartColors: chartColors, chartLineWidth: 30,
                    diameter: 300
                )
                .padding()
                
                BudgetItemsListView(spendings: .constant(budget.subBudgets), idx: $selectedSpendingIdx, chartColors: chartColors
                )
                .frame(height: 170)
                .padding()
            }
            
        }
    }
}
    
#Preview {
    BudgetDetailView(budget: sampleBudgets[0])
}

