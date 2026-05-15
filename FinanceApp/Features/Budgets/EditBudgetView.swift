//
//  EditBudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/13/26.
//

import SwiftUI
import SwiftData

struct EditBudgetView: View {
    let parentBudget: Budget
    
    @State private var selectedSpendingIdx: Int? = nil
    
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 50) {
                
                Text("\(parentBudget.budgetName)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                
                BudgetChartView(
                    parentBudget:
                            .constant(parentBudget),
                    idx: $selectedSpendingIdx,
                    chartColors: chartColors, chartLineWidth: 30,
                    diameter: 300
                )

                CreateSubBudgetView(parentBudget: parentBudget)
                .frame(height: 220)
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
    // Optionally seed with sample data
    // SampleDataSeeder.seed(context: ModelContext(container))
    return EditBudgetView(parentBudget: sampleBudgets[0])
        .modelContainer(container)
        .environment(AppRouter())
}

