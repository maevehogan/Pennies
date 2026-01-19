//
//  BudgetChartView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/17/26.
//

import SwiftUI

struct BudgetChartView: View {
    @Binding var spendings: [Spendings]
    
    @Binding var idx: Int?
    
    let chartColors: [Color]
    let chartLineWidth: CGFloat = 30
    
    
    var body: some View {
        ZStack {
            ForEach(Array(spendings.enumerated()), id: \.element.id) { index, spending in
                let segmentColor = chartColors[index % chartColors.count]
                let chartWidth = idx == index ? chartLineWidth * 1.25 : chartLineWidth
                    
                Circle()
                    .trim(from: startTrim(at: index), to: endTrim(at:index))
                    .stroke(segmentColor, style: StrokeStyle(lineWidth: chartWidth, lineCap: .butt))
                    .frame(width: 300, height: 300)
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
                .frame(width: 300, height: 300)
                .rotationEffect(Angle(degrees: -90))
            VStack(alignment: .center) {
                if let index = idx {
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

    func endTrim(at index: Int) -> Double {
        let trimEnd = startTrim(at: index) + spendings[index].amount
        return trimEnd
    }
}
       
#Preview {
    BudgetChartView(spendings: .constant([]), idx: .constant(0), chartColors: [.pink, .blue, .purple, .indigo, .mint, .cyan])
}

