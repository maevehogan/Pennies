
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

    @State private var openTransactionId: UUID? = nil
    @State private var showMoveSheet: Bool = false
    @State private var transactionToMove: Transaction? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        openTransactionId = nil
                    }
                }

            VStack {
                Text("Recent Transactions:")
                    .font(.title)
                    .foregroundStyle(.blue)
                ScrollView {
                    Spacer()
                    ForEach(transactions) { transaction in
                        TransactionsItemView(
                            transaction: transaction,
                            openTransactionId: $openTransactionId,
                            onMoreTapped: {
                                transactionToMove = transaction
                                showMoveSheet = true
                            }
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
        .sheet(isPresented: $showMoveSheet, onDismiss: {openTransactionId = nil} ) {
            if let transactionToMove = transactionToMove {
                MoveTransactionView(close: { showMoveSheet = false }, transaction: transactionToMove
                )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    
            } else {
                Text("Error Loading Data.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .italic()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                Button {
                    showMoveSheet = false
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                        .cornerRadius(10)
                }
            }
            
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Budget.self,
        SubBudget.self,
        Transaction.self
    )
    // Seed the preview container
    SampleDataSeeder.reset(context: ModelContext(container))
    SampleDataSeeder.seed(context: ModelContext(container))
    
    return TransactionsListView()
        .modelContainer(container)

}
