//
//  BudgetPageItem.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/15/26.
//
import SwiftUI
import Foundation
import SwiftData

struct BudgetPageItem: View {
    let itemWidth: CGFloat = 350
    let itemHeight: CGFloat = 75
    let deleteWidth: CGFloat = 90
    
    let budget: Budget
    
    // Variables for the drag feature
    @State var offsetX: CGFloat = 0
    @Binding var openBudgetId: UUID?
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let progress = budget.spentAmount / budget.totalAmount
        let blendWidth: Double = 0.02
        
        ZStack(alignment: .trailing) {
            
            // BACKGROUND DELETE BUTTON
            Button {
                openBudgetId = nil
                Task {
                    // Delete from server first (uses serverId), then removes locally
                    let sync = SyncService(context: context)
                    try? await sync.deleteBudget(budget)
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                    
                    Text("Delete")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(width: deleteWidth, height: itemHeight)
                .background(Color.red)
                .cornerRadius(14)
            }
            
            // FOREGROUND CARD
            BudgetCard(progress: progress, blendWidth: blendWidth, budget: budget)
                .offset(x: offsetX)
                .onChange(of: openBudgetId) {
                    // If another card becomes active, close this one
                    if openBudgetId != budget.id {
                        withAnimation(.spring()) {
                            offsetX = 0
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow dragging left
                            let translation = value.translation.width
                            
                            if translation < 0 {
                                withAnimation(.spring) {
                                    offsetX = max(translation, -deleteWidth)
                                }
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                // Snap open if dragged far enough
                                if value.translation.width < -40 {
                                    offsetX = -deleteWidth
                                    openBudgetId = budget.id
                                } else {
                                    offsetX = 0
                                    
                                    if openBudgetId == budget.id {
                                        openBudgetId = nil
                                    }
                                }
                            }
                        }
                )
        }
        .frame(width: itemWidth, height: itemHeight)
    }
}

struct BudgetCard: View {
    let progress: Double
    let blendWidth: Double
    let budget: Budget
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(
                            color:Color.blue.opacity(0.6),
                            location: progress - blendWidth),
                        .init(
                            color: Color.black.opacity(0.6),
                            location: progress + blendWidth)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)                    .stroke(Color.white.opacity(0.6), lineWidth: 3)
            )
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black)
            )
            .overlay {
                HStack {
                    Text(budget.budgetName)
                        .padding(.horizontal, 30)
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                    if progress > 0 {
                        Text("\(progress * 100, specifier: "%.1f")%")                            .padding(.horizontal, 30)
                            .font(.headline)
                            .foregroundColor(.white)
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
    return BudgetPageItem(budget: sampleBudgets[0], openBudgetId: .constant(nil))
        .modelContainer(container)
}
