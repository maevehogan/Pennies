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
    @Binding var openTransactionId: UUID?

    let chartColors: [Color]

    @State private var transactionToMove: Transaction? = nil

    var body: some View {
        // Choose which transactions to show based on selection
        let displayedTransactions: [Transaction] = {
            if let selected = idx, spendings.indices.contains(selected) {
                return spendings[selected].transactions
            } else {
                return spendings.flatMap { $0.transactions }
            }
        }()
        VStack(spacing: 0) {
            Text("Transactions")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            if !displayedTransactions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(displayedTransactions.enumerated()), id: \.element.id) { tx in
                        TransactionsItemView(
                            transaction: tx.element,
                            itemColor: idx != nil ? chartColors[idx! % chartColors.count] : .white,
                            openTransactionId: $openTransactionId,
                            onMoreTapped: {
                                transactionToMove = tx.element
                            }
                        )
                    }
                }
                .padding(.bottom, 8)
            } else {
                Text("No transactions under this Budget")
                    .foregroundStyle(.white)
                    .font(.title3)
                    .italic()
            }
        }
        .sheet(item: $transactionToMove, onDismiss: { openTransactionId = nil }) { tx in
            MoveTransactionView(close: { transactionToMove = nil }, transaction: tx)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ZStack {
        Color.black

        BudgetItemsListView(spendings: .constant(sampleBudgets[0].subBudgets), idx: .constant(0), openTransactionId: .constant(nil), chartColors: [.pink, .blue, .purple, .indigo, .mint, .cyan])
        .frame(height: 150)
    }
}
