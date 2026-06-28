//
//  TransactionItemView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/18/26.
//

import SwiftUI
import Foundation
import SwiftData

struct TransactionsItemView: View {
    let deleteWidth: CGFloat = 90
    let moreWidth: CGFloat = 90

    let transaction: Transaction
    var itemColor: Color? = .white

    // Variables for the drag feature
    @State var offsetX: CGFloat = 0
    @Binding var openTransactionId: UUID?

    var swipeEnabled: Bool = true
    var onMoreTapped: (() -> Void)? = nil
    var onDeleteTapped: (() -> Void)? = nil

    private var showsMoreButton: Bool { onMoreTapped != nil }
    private var maxSwipe: CGFloat { showsMoreButton ? deleteWidth + moreWidth : deleteWidth }

    var body: some View {
        ZStack(alignment: .trailing) {
            // BACKGROUND BUTTONS
            HStack(spacing: 0) {
                if showsMoreButton {
                    Button {
                        onMoreTapped?()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: moreWidth, height: 80)
                            .background(Color.gray)
                    }
                }

                Button {
                    onDeleteTapped?()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: deleteWidth, height: 80)
                        .background(Color.red)
                }
            }
            .frame(
                width: max(-offsetX, 0),
                alignment: .trailing
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 14,
                    topTrailingRadius: 14
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 14,
                    topTrailingRadius: 14
                )
                .stroke(itemColor ?? Color.white, lineWidth: 3)
            )

            // FOREGROUND CARD
            TransactionCard(transaction: transaction, itemColor: itemColor, isSwiped: offsetX < 0)
                .offset(x: offsetX)
                .onChange(of: openTransactionId) {
                    // If another card becomes active, close this one
                    if openTransactionId != transaction.id {
                        withAnimation(.spring()) {
                            offsetX = 0
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard swipeEnabled else { return }
                            let translation = value.translation
                            if abs(translation.width) > abs(translation.height) && translation.width < 0 {
                                withAnimation(.spring) {
                                    offsetX = max(translation.width, -maxSwipe)
                                }
                            }
                        }
                        .onEnded { value in
                            guard swipeEnabled else { return }
                            if abs(value.translation.width) > abs(value.translation.height) {
                                withAnimation(.spring(response: 0.3)) {
                                    if value.translation.width < -40 {
                                        offsetX = -maxSwipe
                                        openTransactionId = transaction.id
                                    } else {
                                        offsetX = 0
                                        if openTransactionId == transaction.id {
                                            openTransactionId = nil
                                        }
                                    }
                                }
                            }
                        }
                )
        }
    }
}

struct TransactionCard: View {
    let cardWidth: CGFloat = 350
    let cardHeight: CGFloat = 80
    let transaction: Transaction
    var itemColor: Color? = .blue
    
    let isSwiped: Bool
    
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
        .frame(width: cardWidth, height: cardHeight)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 14,
                bottomLeadingRadius: 14,
                bottomTrailingRadius: isSwiped ? 0 : 14,
                topTrailingRadius: isSwiped ? 0 : 14
            )
            .fill(Color.white.opacity(0.1))
            .stroke(itemColor ?? Color.blue, lineWidth: 3)
        )
        
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TransactionsItemView(transaction: sampleTransactions[0], openTransactionId : .constant(nil))

    }
}

