//  ContentView.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(BudgetsViewModel.self) private var budgetsVM
    @Environment(AppRouter.self) private var router
    let navBudgetDetail: (UUID) -> Void
    let navTransactions: () -> Void
    
    @State private var selectedBudgetIdx: Int = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.95)
            VStack (spacing: 20) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                HomeChartsView(navBudgetDetail: navBudgetDetail, budgets: budgetsVM.budgets, selectedBudgetIdx: $selectedBudgetIdx)
                
                TransactionsListView()
                    .onTapGesture {
                        navTransactions()
                    }
            }
                
        }
        
    }
}

struct HomeChartsView: View {
    let navBudgetDetail: (UUID) -> Void

    let budgets: [Budget]
    @Binding var selectedBudgetIdx: Int

    var body: some View {
        VStack {
            TabView(selection: $selectedBudgetIdx) {
                ForEach(Array(budgets.enumerated()), id: \.element.id) { index, budget in
                    BudgetPage(budget: budget)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navBudgetDetail(budget.id)
                    }
                    .tag(index)
                }
                
                CreateBudgetPage()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Optionally handle create new budget navigation
                    }
                    .tag(budgets.count)
                    

            }
            .frame(height: 400)
            #if os(iOS) || os(tvOS) || os(watchOS)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            #else
            .tabViewStyle(DefaultTabViewStyle())
            #endif
        }
    }
}

struct BudgetPage: View {
    let budget: Budget
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo]

    let chartLineWidth: CGFloat = 20
    let diameter: CGFloat = 250
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0))
                

            VStack {
                Text(budget.budgetName)
                    .font(.headline)
                    .foregroundColor(.white)

                BudgetChartView(
                    parentBudget: .constant(budget),
                    idx: .constant(nil),
                    chartColors: chartColors,
                    chartLineWidth: chartLineWidth,
                    diameter: diameter
                ).padding()
            }
            
        }
    }
}

struct CreateBudgetPage: View {
    let chartLineWidth: CGFloat = 20
    let diameter: CGFloat = 250
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0))
            
            VStack {
                Text("Create New Budget")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack {
                    Button(action: {
                        // Action to create a new budget
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white).opacity(0.7)
                    }
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: chartLineWidth, lineCap: .round))
                        .frame(width: diameter, height: diameter)
                        .rotationEffect(Angle(degrees: -90))
                        .padding()
                }
            }
            
        }
    }
}



#Preview {
    HomeView(navBudgetDetail: {_ in }, navTransactions: {})
        .environment(BudgetsViewModel())
        .environment(TransactionsViewModel())
        .environment(AppRouter())
        
}
