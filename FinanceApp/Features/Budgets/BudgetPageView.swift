//
//  BudgetList.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/26/26.
//

import SwiftUI
import Foundation
import SwiftData

struct BudgetPageView: View {
    let navBudgetDetail: (_ budget: Budget) -> Void
        
    @Environment(AppRouter.self) private var router
    
    @Query var budgets: [Budget]
    
    @State private var openBudgetId: UUID? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        openBudgetId = nil
                    }
                }
            
            VStack {
                Text("Your Budgets")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.top, 30)
                VStack {
                        
                    ForEach(budgets) { budget in
                        BudgetPageItem(
                            budget: budget, openBudgetId: $openBudgetId,
        
                        )
                        .onTapGesture {
                                navBudgetDetail(budget)
                        }
                        .padding(5)
                    }
                    
                    Button(action: {
                        navCreateBudget(router: router)
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white).opacity(0.7)
                            .frame(width: 350, height: 75)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            )
                    }
                    
                    
                    Spacer()
                        
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
    // Seed the preview container
    SampleDataSeeder.seed(context: ModelContext(container))
    
        
    return BudgetPageView(navBudgetDetail: {budgetID in })
        .modelContainer(container)
        .environment(AppRouter())
}

