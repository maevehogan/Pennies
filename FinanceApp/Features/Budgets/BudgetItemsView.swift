//
//  BudgetItemsView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/17/26.
//

import SwiftUI
import Foundation

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
        VStack {
            Text("Transactions")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    // Transactions list
                    if !displayedTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(displayedTransactions.enumerated()), id: \.element.id) { tx in
                                TransactionsItemView(transaction: tx.element, itemColor:
                                        (idx != nil ?  chartColors[idx! % chartColors.count] : .blue
                                    ))
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
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

