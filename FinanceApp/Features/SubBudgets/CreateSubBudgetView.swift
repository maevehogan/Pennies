//
//  CreateSubBudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/13/26.
//

import SwiftUI
import Foundation
import SwiftData

struct CreateSubBudgetView: View {
    let parentBudget: Budget
    
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    @State private var title: String = ""
    @State private var isHovering: Bool = false
    
    @State private var pendingSubBudgetTitles: [String] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                
                VStack(alignment: .center, spacing: 10) {
                    Text("Add a Sub-Budget to \"\(parentBudget.budgetName)\"")
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    HStack {
                        TextField(
                            "",
                            text: $title,
                            prompt: Text("Sub-Budget Name")
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .padding()
                        
                        Button {
                            // add sub-budget but do not save
                            if title != "" {
                                pendingSubBudgetTitles.append(title)
                            }
                            
                            title = ""
                            
                        } label : {
                            Image(systemName: "plus.circle")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                                .background(Color.white.opacity(0.05))
                        }
                            
                    }
                    .background(Color.white.opacity(0.10))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .font(.title2)
                }.padding(.horizontal, 20)
                
                VStack(spacing: 20) {
                    Button {
                        for pendingTitle in pendingSubBudgetTitles {
                            var _ = SubBudgetService.createSubBudget( parentBudget: parentBudget, title: pendingTitle, context: context)
                        }
                        
                        // Clear pending titles
                        pendingSubBudgetTitles = []
                        
                        // Navigate back to the BudgetDetail view you were just on when done
                        navBack(router: router)
                        
                    } label: {
                        Text("Save Changes")
                            .foregroundStyle(.blue).opacity(0.7)
                            .padding(5)
                            .font(.headline)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isHovering ? Color.blue.opacity(0.8)
                                : Color.blue.opacity(0.0)
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.9), lineWidth: 1)
                    )
                    .scaleEffect(isHovering ? 1.05 : 1.0)
                    .shadow(
                        color: .blue.opacity(isHovering ? 0.8 : 0.0),
                        radius: 12
                    )
                    .animation(.easeInOut(duration: 0.2), value: isHovering)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .padding()
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
    // Optionally seed with sample data
    // SampleDataSeeder.seed(context: ModelContext(container))
    return CreateSubBudgetView(parentBudget: sampleBudgets[0])
        .modelContainer(container)
        .environment(AppRouter())
}
