// Question: why can't I set a specific spendings variable in the array to the selectedSpendings variable?

//  BudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import SwiftUI

struct BudgetView: View {
    @State private var spendings: [Spendings] = [
        .init(title: "Groceries", amount: 0.45),
        .init(title: "Rent", amount: 0.35),
        .init(title: "Utilities", amount: 0.10),
        .init(title: "Transport", amount: 0.05),
        .init(title: "Entertainment", amount: 0.05)
    ]
    
    @State private var selectedSpendingIdx: Int? = nil
    
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 50) {
                BudgetChartView(spendings: $spendings, idx: $selectedSpendingIdx, chartColors: chartColors)
                    .padding()
                
                BudgetItemsListView(spendings: $spendings, idx: $selectedSpendingIdx, chartColors: chartColors)
                    // Approx. 2.5 items visible (each ~64–68pt tall with padding/glow)
                    .frame(height: 170)
                    .padding()
            }
        }
    }
}


#Preview {
    BudgetView()
}

