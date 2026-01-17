// Question: why can't I set a specific spendings variable in the array to the selectedSpendings variable?

//  BudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/11/26.
//

import SwiftUI
import Charts

struct BudgetView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            BudgetChartView()
        }
    }
}

struct BudgetChartView: View {
    
    @State private var spendings: [Spendings] = [
        .init(title: "Groceries", amount: 0.45),
        .init(title: "Rent", amount: 0.35),
        .init(title: "Utilities", amount: 0.10),
        .init(title: "Transport", amount: 0.05),
        .init(title: "Entertainment", amount: 0.05)
    ]
    @State private var selectedSpendingIdx: Int? = nil
    let chartColors: [Color] = [.pink, .blue, .purple, .indigo, .mint, .cyan]
    let chartLineWidth: CGFloat = 30

    
    var body: some View {
        ZStack {
            ForEach(Array(spendings.enumerated()), id: \.element.id) { index, spending in
                
                let segmentColor = chartColors[index % chartColors.count]
                let chartWidth = selectedSpendingIdx == index ? chartLineWidth * 1.25 : chartLineWidth
                
                Circle()
                    .trim(from: startTrim(at: index), to: endTrim(at:index))
                    .stroke(segmentColor, style: StrokeStyle(lineWidth: chartWidth, lineCap: .butt))
                    .frame(width: 300, height: 300)
                    .rotationEffect(Angle(degrees: -90))
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            selectedSpendingIdx = (selectedSpendingIdx == index) ? nil : index
                        }
                    }
            }
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: chartLineWidth, lineCap: .round))
                .frame(width: 300, height: 300)
                .rotationEffect(Angle(degrees: -90))
            VStack(alignment: .center) {
                if let index = selectedSpendingIdx {
                    Text("\(spendings[index].title)")
                        .font(.title).bold()
                        .foregroundColor(chartColors[index % chartColors.count])
                    Text(String(format: "$%.2f", spendings[index].amount * 1000))
                        .font(.headline)
                        .foregroundColor(.white)
                } else {
                    EmptyView()
                }
            }
        }
        
    }

    func startTrim(at index: Int) -> Double {
        let previousSegments = spendings.prefix(index)
        let trimStart = previousSegments.reduce(0.0) { $0 + $1.amount }
        return trimStart
    }
    
    func endTrim(at Index: Int) -> Double {
        let trimEnd = startTrim(at: Index) + spendings[Index].amount
        return trimEnd
    }
}



#Preview {
    BudgetView()
}

