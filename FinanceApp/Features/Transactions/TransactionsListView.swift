
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import SwiftUI

struct TransactionsListView: View {
    @Environment(TransactionsViewModel.self) private var transactionsVM
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Recent Transactions:")
                    .font(.title)
                    .foregroundStyle(.blue)
                ScrollView {
                    Spacer()
                    ForEach(Array(transactionsVM.transactions.enumerated()), id: \.element.id) { index, transaction in
                        
                        TransactionsItemView(transaction: transaction)
                            .padding(.horizontal)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    transactionsVM.deleteTransaction(transaction: transaction)
                                }
                                
                            }
                    }
                }
                
            }
        }
    }
}

struct TransactionsItemView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.location_spent)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(transaction.date, format: Date.FormatStyle().month().day())")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(String(format: "$%.2f", transaction.amount_spent))
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 350, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.blue, lineWidth: 3)
        )
        
    }
}

#Preview {
    TransactionsListView()
        .environment(TransactionsViewModel())
    

}
