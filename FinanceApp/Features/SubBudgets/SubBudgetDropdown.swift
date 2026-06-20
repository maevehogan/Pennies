//
//  SubBudgetDropdown.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/13/26.
//
import Foundation
import SwiftUI
import SwiftData

struct SubBudgetDropdown: View {

    @Environment(AppRouter.self) private var router
    
    let parentBudget: Budget
    let subBudgets: [SubBudget]

    @Binding var subBudgetIdx: Int?
    let colors: [Color]
    
    @State private var isExpanded = false

    var body: some View {

        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        } label: {

            Image(systemName:
                isExpanded
                ? "chevron.up"
                : "chevron.down"
            )
            .foregroundColor(.white)
            .padding(10)
            .background(Color.white.opacity(0.1))
            .clipShape(Circle())
        }

        .overlay(alignment: .top) {

            if isExpanded {

                VStack(spacing: 5) {

                    ForEach(
                        subBudgets.filter { !$0.title.isEmpty },
                        id: \.persistentModelID
                    ) { subBudget in
                        // Find the index of this subBudget in the parentBudget.subBudgets array
                        let idx = parentBudget.subBudgets.firstIndex(where: { $0.id == subBudget.id }) ?? 0
                        
                        HStack {
                            
                            Text(subBudget.title)
                                .foregroundColor(colors[idx % colors.count])
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(width: 180)
                        .background(Color.black.opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.white.opacity(0.1)
                                )
                        )
                        .cornerRadius(10)
                        .onTapGesture {
                            // Set the selected sub-budget index to this sub-budget's index in the parent budget
                        
                            withAnimation(.easeInOut(duration: 0.25)) {
                                subBudgetIdx = idx
                                isExpanded = false
                            }
                        }
                    }
                    
                    HStack {

                        Text("Add More")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.white)
                            .padding(.trailing, 8)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(width: 180)
                    .background(Color.black.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.white.opacity(0.1)
                            )
                    )
                    .cornerRadius(10)
                    .onTapGesture {
                        // Move to the add create sub-budget page
                        navAddSubBudget(router: router, parentBudget: parentBudget)
                    }
                }
                .padding(5)
                .background(Color.white.opacity(0.15))
                .padding(.top, 45)
                .shadow(radius: 10)
                .transition(
                    .opacity
                    .combined(with: .scale(scale: 0.95))
                )
                .zIndex(100)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SubBudgetDropdown(parentBudget: sampleBudgets[0], subBudgets: sampleBudgets[0].subBudgets, subBudgetIdx: .constant(nil), colors: [.pink, .blue, .green])
            .frame(maxWidth: 300)
    }
    .environment(AppRouter())

}
