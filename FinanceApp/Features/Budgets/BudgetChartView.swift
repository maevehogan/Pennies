//
//  BudgetChartView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/17/26.
//

import SwiftUI

struct BudgetChartView: View {
    @Binding var parentBudget: Budget
    
    @Binding var idx: Int?
    
    let chartColors: [Color]
    let chartLineWidth: CGFloat
    let diameter: CGFloat
    
    
    var body: some View {
        ZStack {
            ForEach(Array(parentBudget.subBudgets.enumerated()), id: \.element.id) { index, spending in
                let segmentColor = chartColors[index % chartColors.count]
                let chartWidth = idx == index ? chartLineWidth * 1.25 : chartLineWidth
                    
                Circle()
                    .trim(from: startTrim(at: index), to: endTrim(at:index))
                    .stroke(segmentColor, style: StrokeStyle(lineWidth: chartWidth, lineCap: .butt))
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(Angle(degrees: -90))
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            idx = (idx == index) ? nil : index
                        }
                    }
            }
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: chartLineWidth, lineCap: .round))
                .frame(width: diameter, height: diameter)
                .rotationEffect(Angle(degrees: -90))
            VStack(alignment: .center) {
                if let index = idx {
                    Text("\(parentBudget.subBudgets[index].title)")
                        .font(.title).bold()
                        .foregroundColor(chartColors[index % chartColors.count])
                    Text(String(format: "$%.2f", parentBudget.subBudgets[index].amount))
                        .font(.headline)
                        .foregroundColor(.white)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    func startTrim(at index: Int) -> Double {
        let previousSegments = parentBudget.subBudgets.prefix(index)
        let trimStart = previousSegments.reduce(0.0) { $0 + ($1.amount / parentBudget.totalAmount) }
        return trimStart
    }

    func endTrim(at index: Int) -> Double {
        let trimEnd = startTrim(at: index) + (parentBudget.subBudgets[index].amount / parentBudget.totalAmount)
        return trimEnd
    }
}
       
#Preview {
    BudgetChartView(parentBudget: .constant(sampleBudgets[0]), idx: .constant(nil), chartColors: [.pink, .blue, .purple], chartLineWidth: 30, diameter: 300)
}
