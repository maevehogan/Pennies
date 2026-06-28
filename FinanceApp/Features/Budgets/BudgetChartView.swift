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
    
    let minimumVisibleSize = 0.003
    
    var body: some View {
        ZStack {
            // Background track — matches the "create budget" gradient ring
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    LinearGradient(
                        colors: [Color.hotPink.opacity(0.25), Color.electricBlue.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: chartLineWidth, lineCap: .round)
                )
                .frame(width: diameter, height: diameter)
                .rotationEffect(Angle(degrees: -90))

            // Subbudget segments — semi-transparent so the glow shows through
            ForEach(Array(parentBudget.subBudgets.enumerated()), id: \.element.id) { index, spending in
                let segmentColor = chartColors[index % chartColors.count]
                let isSelected = idx == index
                let chartWidth = isSelected ? chartLineWidth * 1.25 : chartLineWidth

                Circle()
                    .trim(from: startTrim(at: index), to: endTrim(at: index))
                    .stroke(
                        segmentColor.opacity(isSelected ? 0.85 : 0.55),
                        style: StrokeStyle(lineWidth: chartWidth, lineCap: .round)
                    )
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(Angle(degrees: -90))
                    .zIndex(1)
                    .animation(.spring(response: 0.3), value: isSelected)
                    .onTapGesture {
                        withAnimation {
                            idx = (idx == index) ? nil : index
                        }
                    }
            }
            VStack(alignment: .center) {
                if let index = idx {
                    Text("\(parentBudget.subBudgets[index].title)")
                        .font(.title).bold()
                        .foregroundColor(chartColors[index % chartColors.count])
                    Text(String(format: "$%.2f", parentBudget.subBudgets[index].amount) + " / " + String(format: "$%.2f", parentBudget.totalAmount))
                        .font(.headline)
                        .foregroundColor(.white)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    func visibleSize(for spending: SubBudget) -> Double {
        let percentage = spending.amount / parentBudget.totalAmount
        return percentage == 0 ? minimumVisibleSize : percentage
    }
    
    func startTrim(at index: Int) -> Double {
        parentBudget.subBudgets
            .prefix(index)
            .reduce(0.0) { partial, spending in
                partial + visibleSize(for: spending)
            }
    }

    func endTrim(at index: Int) -> Double {
        startTrim(at: index)
            + visibleSize(for: parentBudget.subBudgets[index])
    }
}
       
#Preview {
    BudgetChartView(parentBudget: .constant(sampleBudgets[0]), idx: .constant(nil), chartColors: [.pink, .blue, .purple], chartLineWidth: 30, diameter: 300)
}
