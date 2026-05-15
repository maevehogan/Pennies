//  ContentView.swift
//  finance-app
//
//  Created by Maeve Hogan on 1/3/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    
    @Query var budgets: [Budget]
    
    let navBudgetDetail: (Budget) -> Void
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
                HomeChartsView(
                    navBudgetDetail: navBudgetDetail,
                    budgets: budgets,
                    router: router,
                    selectedBudgetIdx: $selectedBudgetIdx,
                    )
                
                TransactionsListView()
                    .onTapGesture {
                        navTransactions()
                    }
            }
                
        }
        
    }
}

struct HomeChartsView: View {
    let navBudgetDetail: (Budget) -> Void
    let budgets: [Budget]
    let router: AppRouter
    
    @Binding var selectedBudgetIdx: Int

    var body: some View {
        VStack {
            TabView(selection: $selectedBudgetIdx) {
                ForEach(Array(budgets.enumerated()), id: \.element.id) { index, budget in
                    BudgetPage(budget: budget)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navBudgetDetail(budget)
                    }
                    .tag(index)
                }
                
                CreateBudgetPage(router: router)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navCreateBudget(router: router)
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
    
    let router: AppRouter
    
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
                        navCreateBudget(router: router)
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
        .environment(TransactionsViewModel())
        .environment(AppRouter())
        
}
