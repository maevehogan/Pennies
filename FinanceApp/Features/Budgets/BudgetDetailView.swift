//  BudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import SwiftUI

struct BudgetDetailView: View {
    let budgetID: UUID
    @Environment(BudgetsViewModel.self) private var budgetsVM
    @State private var vm: BudgetViewModel
    
    init(budgetID: UUID) {
        self.budgetID = budgetID
        _vm = State(initialValue: BudgetViewModel(budgetID: budgetID))
    }
    
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            
            if let budget = budgetsVM.budgets.first(where: { $0.id == budgetID }) {
                VStack(spacing: 50) {
                    Text("\(budget.budgetName)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    BudgetChartView(parentBudget: .constant(budget), idx: $vm.selectedSpendingIdx, chartColors: chartColors, chartLineWidth: 30, diameter: 300)
                        .padding()
                        
                    BudgetItemsListView(spendings: .constant(vm.spendings), idx: $vm.selectedSpendingIdx, chartColors: chartColors)
                        .frame(height: 170)
                        .padding()
                }
            } else {
                Text("Budget not found.")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
}


#Preview {
    BudgetDetailView(budgetID: UUID())
        .environment(BudgetViewModel(budgetID: UUID()))
        .environment(BudgetsViewModel())
}
