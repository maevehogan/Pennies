//
//  CreateSubBudgetView.swift
//  FinanceApp
//

import SwiftUI
import Foundation
import SwiftData

struct CreateSubBudgetView: View {
    let parentBudget: Budget

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    @State private var title: String = ""
    @State private var pendingSubBudgetTitles: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            // Section label
            Text("Add Sub-Budgets")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.4))
                .textCase(.uppercase)
                .tracking(1.2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Input row
            HStack(spacing: 10) {
                TextField("", text: $title,
                    prompt: Text("Sub-budget name").foregroundColor(Color.white.opacity(0.35))
                )
                .foregroundStyle(.white)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )

                Button {
                    let trimmed = title.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    withAnimation(.spring(response: 0.3)) {
                        pendingSubBudgetTitles.append(trimmed)
                    }
                    title = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            title.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.white.opacity(0.2)
                                : Color.electricBlue
                        )
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .animation(.easeInOut(duration: 0.15), value: title.isEmpty)
            }

            // Pending list
            if !pendingSubBudgetTitles.isEmpty {
                VStack(spacing: 6) {
                    ForEach(pendingSubBudgetTitles, id: \.self) { name in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(Color.electricBlue.opacity(0.6))
                            Text(name)
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.75))
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    pendingSubBudgetTitles.removeAll { $0 == name }
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundStyle(Color.white.opacity(0.3))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassCard(cornerRadius: 10)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Save button
            Button {
                for pendingTitle in pendingSubBudgetTitles {
                    _ = SubBudgetService.createSubBudget(parentBudget: parentBudget, title: pendingTitle, context: context)
                }
                pendingSubBudgetTitles = []
                navBack(router: router)
            } label: {
                Text(pendingSubBudgetTitles.isEmpty ? "Save" : "Save \(pendingSubBudgetTitles.count) Sub-Budget\(pendingSubBudgetTitles.count == 1 ? "" : "s")")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Group {
                            if pendingSubBudgetTitles.isEmpty {
                                Color.white.opacity(0.06)
                            } else {
                                LinearGradient(colors: [.electricBlue, .neonPurple], startPoint: .leading, endPoint: .trailing)
                            }
                        }
                    )
                    .foregroundStyle(pendingSubBudgetTitles.isEmpty ? Color.white.opacity(0.3) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(pendingSubBudgetTitles.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: pendingSubBudgetTitles.isEmpty)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let container = try! ModelContainer(for: Budget.self, SubBudget.self, Transaction.self)
    return ZStack {
        AppBackground()
        CreateSubBudgetView(parentBudget: sampleBudgets[0])
    }
    .modelContainer(container)
    .environment(AppRouter())
}
