//
//  CreateBudgetView.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/9/26.
//

import SwiftUI
import Foundation
import SwiftData

struct CreateBudgetView: View {
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 10) {
                GradientLabel("Create a Budget", font: .title.bold())
                CreateBudgetForm()
            }
        }
        .presentationBackground(Color.appBg)
        
    }
    
    
}

struct CreateBudgetForm: View {
    @Environment(\.modelContext) private var context

    @State private var budgetName: String = ""
    @State private var isSaving = false

    @State private var thousands: Int = 0
    @State private var hundreds: Int = 0
    @State private var tens: Int = 0
    @State private var ones: Int = 0

    @Environment(AppRouter.self) private var router
    
    var totalAmount: Double {
        return Double(thousands + hundreds + tens + ones)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Budget Title VStack
            VStack (alignment: .leading, spacing: 20) {
                TextField(
                    "",
                    text: $budgetName,
                    prompt: Text("Budget Name")
                        .foregroundColor(.white.opacity(0.5))
                )
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .foregroundColor(.white)
                .font(.title2)
            }
            .padding(.vertical, 30)
            .padding(.horizontal)
            
            // Total Amount VStack
            VStack (alignment: .center, spacing: 8) {
                
                Text("Total Amount")
                    .foregroundColor(.gray)
                    .font(.title2)
                
                Text("$\(totalAmount, specifier: "%.2f")")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: totalAmount)
                    
                
                HStack {
                    VStack {
                        Text("\(thousands)")
                            .foregroundColor(.white)
                            .font(.title2)
                        Stepper("", value: $thousands, in: 0...50000, step: 1000)
                            .foregroundColor(.white)
                            .labelsHidden()
                        Text("Thousands")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(hundreds)")
                            .foregroundColor(.white)
                            .font(.title2)
                        Stepper("", value: $hundreds, in: 0...900, step: 100)
                            .foregroundColor(.white)
                            .labelsHidden()
                        Text("Hundreds")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(tens)")
                            .foregroundColor(.white)
                            .font(.title2)
                        Stepper("", value: $tens, in: 0...90, step: 10)
                            .foregroundColor(.white)
                            .labelsHidden()
                        Text("Tens")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(ones)")
                            .foregroundColor(.white)
                            .font(.title2)
                        Stepper("", value: $ones, in: 0...9, step: 1)
                            .foregroundColor(.white)
                            .labelsHidden()
                        Text("Ones")
                            .foregroundColor(.gray)
                    }
                            
                }
                
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Button {
                    Task {
                        isSaving = true
                        defer { isSaving = false }

                        // Insert into SwiftData first so the UI updates immediately
                        let newBudget = BudgetService.createBudget(
                            budgetName: budgetName,
                            totalAmount: totalAmount,
                            context: context
                        )

                        // Push to the server and save the returned serverId locally
                        let sync = SyncService(context: context)
                        try? await sync.createBudget(
                            name: budgetName,
                            totalAmount: totalAmount,
                            localBudget: newBudget
                        )

                        // Clear form and navigate back
                        budgetName = ""
                        thousands = 0
                        hundreds = 0
                        tens = 0
                        ones = 0
                        router.budgetsPath = []
                    }
                } label: {
                    VStack(spacing: 8) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.electricBlue)
                            Text("Create")
                                .foregroundStyle(Color.electricBlue)
                                .font(.title2)
                        }
                    }
                }.disabled(budgetName == "" || totalAmount <= 0 || isSaving)
                
            }
        }.padding()
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
    return CreateBudgetView()
        .modelContainer(container)
        .environment(AppRouter())
}
