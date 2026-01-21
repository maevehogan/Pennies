//
//  BudgetItemsView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 1/17/26.
//

import SwiftUI

struct BudgetItemsView: View {
    let item: Spendings
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
    @Binding var spendings: [Spendings]
    @Binding var idx: Int?
    
    let chartColors: [Color]
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack {
                ForEach(Array(spendings.enumerated()), id: \.element.id) { index, spending in
                    
                    let color: Color = chartColors[index % chartColors.count]
                    
                    let isRowSelected = Binding<Bool>(
                        get: { idx == index },
                        set: { newValue in idx = newValue ? index : nil }
                    )
                    
                    BudgetItemsView(item: spending, color: color, isSelected: isRowSelected)
                        .onTapGesture {
                            withAnimation {
                                idx = (idx == index) ? nil : index
                            }
                        }
                
                }
            }
            .padding()
        }
    }
}
#Preview {
    ZStack {
        Color.black
        
        BudgetItemsListView(spendings: .constant([
            .init(title: "Groceries", amount: 0.45),
            .init(title: "Rent", amount: 0.35),
            .init(title: "Utilities", amount: 0.10),
            .init(title: "Transport", amount: 0.05),
            .init(title: "Entertainment", amount: 0.05)
        ]), idx: .constant(0), chartColors: [.pink, .blue, .purple, .indigo, .mint, .cyan])
        .frame(maxHeight: 100)
    }
}

