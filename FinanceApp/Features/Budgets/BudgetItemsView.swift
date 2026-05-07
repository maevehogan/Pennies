//
//  BudgetItemsView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/17/26.
//

import SwiftUI
import Foundation

struct BudgetItemsView: View {
    let item: SubBudget
    let color: Color
    var scale: CGFloat = 1.1

    @Binding var isSelected: Bool
    var borderColor: Color { isSelected ? color : .white }
    var itemWidth: CGFloat { isSelected ? 220*scale : 220 }
    var itemHeight: CGFloat { isSelected ? 56*scale : 56 }
    
    var body: some View {
        ZStack {
            Text("\(item.title): \(String(format: "%.2f", item.amount))")
                .font(.headline)
                .frame(width: itemWidth, height: itemHeight)
                .foregroundColor(color)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black)
                )
                // Core glow layers
                .overlay(
                    ZStack {
                        // Soft outer glow
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor.opacity(0.35), lineWidth: 6)
                            .blur(radius: isSelected ? 6*scale : 6)
                            .opacity(0.9)

                        // Mid glow
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor.opacity(0.6), lineWidth: 2.5)
                            .blur(radius: isSelected ? 2*scale : 2)
                            .opacity(0.9)

                        // Crisp inner stroke
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor, lineWidth: 1)
                    }
                )
                // Optional drop shadow to lift from background
                .shadow(color: borderColor.opacity(0.12), radius: isSelected ? 10*scale : 10, x: 0, y: 0)
                .shadow(color: Color.black.opacity(0.8), radius: isSelected ? 18*scale : 18, x: 0, y: 8)
                .padding(6)
        }
        
    }
}

struct BudgetItemsListView: View {
    @Binding var spendings: [SubBudget]
    @Binding var idx: Int?
    
    
    let chartColors: [Color]
    
    var body: some View {
        // Choose which transactions to show based on selection
        let displayedTransactions: [Transaction] = {
            if let selected = idx, spendings.indices.contains(selected) {
                return spendings[selected].transactions
            } else {
                return spendings.flatMap { $0.transactions }
            }
        }()

        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                // Transactions list
                if !displayedTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transactions")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)

                        ForEach(Array(displayedTransactions.enumerated()), id: \.element.id) { tx in
                            TransactionsItemView(transaction: tx.element, itemColor: chartColors[idx ?? 0 % chartColors.count])
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding()
        }
    }
}
#Preview {
    ZStack {
        Color.black
        
        BudgetItemsListView(spendings: .constant(sampleBudgets[0].subBudgets
        ), idx: .constant(0), chartColors: [.pink, .blue, .purple, .indigo, .mint, .cyan])
        .frame(maxHeight: 100)
    }
}

