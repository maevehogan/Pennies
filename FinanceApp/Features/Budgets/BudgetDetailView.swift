//  BudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import SwiftUI

struct BudgetDetailView: View {
    //let budgetID: UUID
    
    
    @State private var vm = BudgetViewModel()
    
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 50) {
                BudgetChartView(spendings: $vm.spendings, idx: $vm.selectedSpendingIdx, chartColors: chartColors, chartLineWidth: 30, diameter: 300)
                    .padding()
                
                BudgetItemsListView(spendings: $vm.spendings, idx: $vm.selectedSpendingIdx, chartColors: chartColors)
                    // Approx. 2.5 items visible (each ~64–68pt tall with padding/glow)
                    .frame(height: 170)
                    .padding()
            }
        }
    }
}


#Preview {
    BudgetDetailView()
        .environment(BudgetViewModel())
}

