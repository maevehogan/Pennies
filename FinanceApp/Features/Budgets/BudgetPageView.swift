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
    
    @Environment(BudgetsViewModel.self) private var budgetsVM
    
    @Query var budgets: [Budget]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Your Budgets")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.top, 30)
                VStack {
                    ForEach(budgets) { budget in
                        BudgetPageItem(budget: budget)
                            .onTapGesture {
                                navBudgetDetail(budget)
                            }
                            .padding(5)
                    }
                    Spacer()
                    
                }

            }
                            
        }
    }
}

struct BudgetPageItem: View {
    let itemWidth: CGFloat = 350
    let itemHeight: CGFloat = 75
    
    let budget: Budget
    
    var body: some View {
        let progress = budget.spentAmount / budget.totalAmount
        let blendWidth: Double = 0.08
        
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.blue.opacity(0.9), location: progress - blendWidth),
                            .init(color: Color.blue.opacity(0.6), location: progress + blendWidth)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.6), lineWidth: 3)
                )
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.purple.opacity(0.5))
                )
                
            HStack {
                Text("\(budget.budgetName)")
                    .padding(30)
                    .font(.title2)
                    .foregroundColor(.white)
                Spacer()
                if progress > 0 {
                    Text("\(progress * 100, specifier: "%.1f")%")
                        .padding(30)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }.frame(width: itemWidth, height: itemHeight)
        
    }
}

#Preview {
    BudgetPageView(navBudgetDetail: {budgetID in })
}

