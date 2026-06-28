//
//  BudgetPageItem.swift
//  FinanceApp
//

import SwiftUI
import Foundation
import SwiftData

struct BudgetPageItem: View {
    let itemHeight: CGFloat = 72
    let deleteWidth: CGFloat = 90

    let budget: Budget

    @State var offsetX: CGFloat = 0
    @Binding var openBudgetId: UUID?
    @State private var showDeleteConfirm = false

    @Environment(\.modelContext) private var context

    var body: some View {
        let progress = budget.spentAmount / budget.totalAmount

        ZStack(alignment: .trailing) {
            // Delete button
            Button {
                showDeleteConfirm = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill").font(.title3)
                    Text("Delete").font(.caption)
                }
                .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.5))
                .frame(width: deleteWidth, height: itemHeight)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.6, green: 0.1, blue: 0.15).opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.3), lineWidth: 1)
                        )
                )
            }

            BudgetCard(progress: progress, budget: budget)
                .offset(x: offsetX)
                .onChange(of: openBudgetId) {
                    if openBudgetId != budget.id {
                        withAnimation(.spring()) { offsetX = 0 }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                withAnimation(.spring) {
                                    offsetX = max(value.translation.width, -deleteWidth)
                                }
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -40 {
                                    offsetX = -deleteWidth
                                    openBudgetId = budget.id
                                } else {
                                    offsetX = 0
                                    if openBudgetId == budget.id { openBudgetId = nil }
                                }
                            }
                        }
                )
        }
        .frame(height: itemHeight)
        .alert("Delete \"\(budget.budgetName)\"?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                withAnimation(.spring(response: 0.3)) { openBudgetId = nil }
                Task {
                    let sync = SyncService(context: context)
                    try? await sync.deleteBudget(budget)
                }
            }
            Button("Cancel", role: .cancel) {
                withAnimation(.spring(response: 0.3)) { offsetX = 0; openBudgetId = nil }
            }
        } message: {
            Text("This will permanently delete the budget and all its transactions.")
        }
    }
}

struct BudgetCard: View {
    let progress: Double
    let budget: Budget

    var body: some View {
        ZStack(alignment: .leading) {
            // Opaque base so the delete button doesn't bleed through the glass
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appBg)

            // Filled progress bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.electricBlue.opacity(0.5), Color.hotPink.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * min(progress, 1.0))
                    .animation(.spring(response: 0.5), value: progress)
            }

            // Glass overlay
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))

            // Border
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            // Labels
            HStack {
                Text(budget.budgetName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                Spacer()
                if progress > 0 {
                    Text("\(progress * 100, specifier: "%.1f")%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(progress >= 1 ? Color.hotPink : Color.white.opacity(0.8))
                        .padding(.trailing, 20)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.electricBlue.opacity(0.1), radius: 8, y: 4)
    }
}

#Preview {
    ZStack {
        AppBackground()
        BudgetPageItem(budget: sampleBudgets[0], openBudgetId: .constant(nil))
            .padding(.horizontal, 20)
    }
}
