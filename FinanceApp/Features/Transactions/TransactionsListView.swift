
//  TransactionsListView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/24/26.
//

import SwiftUI
import SwiftData

struct TransactionsListView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Recent Transactions:")
                    .font(.title)
                    .foregroundStyle(.blue)
                ScrollView {
                    Spacer()
                    ForEach(transactions, id: \.id) { transaction in
                        
                        TransactionsItemView(transaction: transaction)
                            .padding(.horizontal)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    context.delete(transaction)
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
    var itemColor: Color? = .blue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.location_spent)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(transaction.date, format: Date.FormatStyle().month().day())")
                    .font(.subheadline)
                    .foregroundColor(itemColor ?? Color.blue)
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
                .stroke(itemColor ?? Color.blue, lineWidth: 3)
        )
        
    }
}

#Preview {
    TransactionsListView()

}
