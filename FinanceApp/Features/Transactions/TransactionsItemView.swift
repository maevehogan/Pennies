//
//  TransactionItemView.swift
//  FinanceApp
//

import SwiftUI
import Foundation
import SwiftData

struct TransactionsItemView: View {
    let deleteWidth: CGFloat = 90
    let moreWidth: CGFloat = 90

    let transaction: Transaction
    var itemColor: Color? = .electricBlue

    @State var offsetX: CGFloat = 0
    @Binding var openTransactionId: UUID?

    var swipeEnabled: Bool = true
    var onMoreTapped: (() -> Void)? = nil
    var onDeleteTapped: (() -> Void)? = nil

    private var showsMoreButton: Bool { onMoreTapped != nil }
    private var maxSwipe: CGFloat { showsMoreButton ? deleteWidth + moreWidth : deleteWidth }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Background action buttons
            HStack(spacing: 0) {
                if showsMoreButton {
                    Button {
                        onMoreTapped?()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: moreWidth, height: 64)
                            .background(Color.white.opacity(0.15))
                    }
                }

                Button {
                    onDeleteTapped?()
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: deleteWidth, height: 64)
                        .background(Color.red.opacity(0.8))
                }
            }
            .frame(width: max(-offsetX, 0), alignment: .trailing)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 16, topTrailingRadius: 16
                )
            )

            TransactionCard(transaction: transaction, itemColor: itemColor ?? .electricBlue, isSwiped: offsetX < 0)
                .offset(x: offsetX)
                .onChange(of: openTransactionId) {
                    if openTransactionId != transaction.id {
                        withAnimation(.spring()) { offsetX = 0 }
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard swipeEnabled else { return }
                            let t = value.translation
                            if abs(t.width) > abs(t.height) && t.width < 0 {
                                withAnimation(.spring) {
                                    offsetX = max(t.width, -maxSwipe)
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
                                        if openTransactionId == transaction.id { openTransactionId = nil }
                                    }
                                }
                            }
                        }
                )
        }
    }
}

struct TransactionCard: View {
    let transaction: Transaction
    var itemColor: Color = .electricBlue
    let isSwiped: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Icon bubble
            ZStack {
                Circle()
                    .fill(itemColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "cart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(itemColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.location_spent)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("\(transaction.date, format: Date.FormatStyle().month().day())")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.45))
            }

            Spacer()

            Text(String(format: "$%.2f", transaction.amount_spent))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 16, bottomLeadingRadius: 16,
                bottomTrailingRadius: isSwiped ? 0 : 16,
                topTrailingRadius: isSwiped ? 0 : 16
            )
            .fill(Color.white.opacity(0.07))
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 16, bottomLeadingRadius: 16,
                bottomTrailingRadius: isSwiped ? 0 : 16,
                topTrailingRadius: isSwiped ? 0 : 16
            )
            .strokeBorder(
                LinearGradient(
                    colors: [itemColor.opacity(0.5), itemColor.opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
        )
    }
}

#Preview {
    ZStack {
        AppBackground()
        TransactionsItemView(transaction: sampleTransactions[0], openTransactionId: .constant(nil))
            .padding(.horizontal, 20)
    }
}
