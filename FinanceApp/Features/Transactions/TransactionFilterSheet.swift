//
//  TransactionFilterSheet.swift
//  FinanceApp
//

import SwiftUI

// MARK: - Filter State

struct TransactionFilters {

    enum BudgetFilter: Equatable {
        case all
        case specific(budgetId: UUID)
        case unassigned
    }

    enum DateFilter: Equatable {
        case all
        case today
        case thisWeek
        case thisMonth
        case custom(start: Date, end: Date)
    }

    enum SourceFilter: Equatable {
        case all
        case manual
        case institution(String)
    }

    var budgetFilter: BudgetFilter = .all
    var dateFilter: DateFilter = .all
    var sourceFilter: SourceFilter = .all

    var isActive: Bool { budgetFilter != .all || dateFilter != .all || sourceFilter != .all }

    var activeCount: Int {
        (budgetFilter != .all ? 1 : 0) + (dateFilter != .all ? 1 : 0) + (sourceFilter != .all ? 1 : 0)
    }
}

// MARK: - Filter Sheet

struct TransactionFilterSheet: View {
    @Binding var filters: TransactionFilters
    let budgets: [Budget]
    let institutionNames: [String]

    @Environment(\.dismiss) private var dismiss

    @State private var customStart: Date = Calendar.current.startOfDay(for: Date())
    @State private var customEnd: Date = Date()

    private var isCustomDateSelected: Bool {
        if case .custom = filters.dateFilter { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                Form {
                    dateSection
                    budgetSection
                    sourceSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") { filters = TransactionFilters() }
                        .foregroundStyle(filters.isActive ? Color.hotPink : Color.white.opacity(0.3))
                        .disabled(!filters.isActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.electricBlue)
                        .bold()
                }
            }
        }
        .presentationBackground { AppBackground() }
    }

    // MARK: Date section

    private var dateSection: some View {
        Section {
            filterRow(label: "All Time", isSelected: filters.dateFilter == .all) {
                filters.dateFilter = .all
            }
            filterRow(label: "Today", isSelected: filters.dateFilter == .today) {
                filters.dateFilter = .today
            }
            filterRow(label: "Last 7 Days", isSelected: filters.dateFilter == .thisWeek) {
                filters.dateFilter = .thisWeek
            }
            filterRow(label: "This Month", isSelected: filters.dateFilter == .thisMonth) {
                filters.dateFilter = .thisMonth
            }
            filterRow(label: "Custom Range", isSelected: isCustomDateSelected) {
                filters.dateFilter = .custom(start: customStart, end: customEnd)
            }

            if isCustomDateSelected {
                DatePicker("Start", selection: $customStart, displayedComponents: .date)
                    .foregroundStyle(.white)
                    .tint(Color.electricBlue)
                    .onChange(of: customStart) {
                        filters.dateFilter = .custom(start: customStart, end: customEnd)
                    }
                DatePicker("End", selection: $customEnd, in: customStart..., displayedComponents: .date)
                    .foregroundStyle(.white)
                    .tint(Color.electricBlue)
                    .onChange(of: customEnd) {
                        filters.dateFilter = .custom(start: customStart, end: customEnd)
                    }
            }
        } header: {
            Text("Date Range")
                .foregroundStyle(Color.white.opacity(0.4))
                .font(.caption.weight(.semibold))
                .tracking(1)
        }
        .listRowBackground(Color.white.opacity(0.07))
        .listRowSeparatorTint(Color.white.opacity(0.1))
    }

    // MARK: Budget section

    private var budgetSection: some View {
        Section {
            filterRow(label: "All Budgets", isSelected: filters.budgetFilter == .all) {
                filters.budgetFilter = .all
            }
            filterRow(label: "Unassigned", isSelected: filters.budgetFilter == .unassigned) {
                filters.budgetFilter = .unassigned
            }
            ForEach(budgets, id: \.id) { budget in
                if budget.budgetName != "__unassigned__" {
                    filterRow(
                        label: budget.budgetName,
                        isSelected: filters.budgetFilter == .specific(budgetId: budget.id)
                    ) {
                        filters.budgetFilter = .specific(budgetId: budget.id)
                    }
                }
            }
        } header: {
            Text("Budget")
                .foregroundStyle(Color.white.opacity(0.4))
                .font(.caption.weight(.semibold))
                .tracking(1)
        }
        .listRowBackground(Color.white.opacity(0.07))
        .listRowSeparatorTint(Color.white.opacity(0.1))
    }

    // MARK: Source section

    private var sourceSection: some View {
        Section {
            filterRow(label: "All Sources", isSelected: filters.sourceFilter == .all) {
                filters.sourceFilter = .all
            }
            filterRow(label: "Manual", isSelected: filters.sourceFilter == .manual) {
                filters.sourceFilter = .manual
            }
            ForEach(institutionNames, id: \.self) { name in
                filterRow(label: name, isSelected: filters.sourceFilter == .institution(name)) {
                    filters.sourceFilter = .institution(name)
                }
            }
        } header: {
            Text("Source")
                .foregroundStyle(Color.white.opacity(0.4))
                .font(.caption.weight(.semibold))
                .tracking(1)
        }
        .listRowBackground(Color.white.opacity(0.07))
        .listRowSeparatorTint(Color.white.opacity(0.1))
    }

    private func filterRow(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundStyle(Color.white.opacity(0.85))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.electricBlue)
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
    }
}

#Preview {
    TransactionFilterSheet(filters: .constant(TransactionFilters()), budgets: sampleBudgets, institutionNames: ["Chase", "Wells Fargo"])
}
