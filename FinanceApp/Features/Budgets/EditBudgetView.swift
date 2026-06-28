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
    
    var body: some View {
        ZStack(alignment: .center) {
            AppBackground()

            VStack(spacing: 40) {
                GlowText(parentBudget.budgetName, font: .title.bold(), glowColors: [.electricBlue, .hotPink])

                BudgetChartView(
                    parentBudget: .constant(parentBudget),
                    idx: $selectedSpendingIdx,
                    chartColors: appChartColors,
                    chartLineWidth: 28,
                    diameter: 280
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

