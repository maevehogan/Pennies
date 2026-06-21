//
//  TransactionFilterSheet.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 6/19/26.
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

    var budgetFilter: BudgetFilter = .all
    var dateFilter: DateFilter = .all

    var isActive: Bool { budgetFilter != .all || dateFilter != .all }

    var activeCount: Int {
        (budgetFilter != .all ? 1 : 0) + (dateFilter != .all ? 1 : 0)
    }
}

// MARK: - Filter Sheet

struct TransactionFilterSheet: View {
    @Binding var filters: TransactionFilters
    let budgets: [Budget]

    @Environment(\.dismiss) private var dismiss

    // Local state for custom date pickers — synced into filters on change
    @State private var customStart: Date = Calendar.current.startOfDay(for: Date())
    @State private var customEnd: Date = Date()

    private var isCustomDateSelected: Bool {
        if case .custom = filters.dateFilter { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                dateSection
                budgetSection
            }
            .navigationTitle("Filter Transactions")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        filters = TransactionFilters()
                    }
                    .disabled(!filters.isActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
        }
    }

    // MARK: Date section

    private var dateSection: some View {
        Section("Date Range") {
            dateRow(label: "All Time", isSelected: filters.dateFilter == .all) {
                filters.dateFilter = .all
            }
            dateRow(label: "Today", isSelected: filters.dateFilter == .today) {
                filters.dateFilter = .today
            }
            dateRow(label: "Last 7 Days", isSelected: filters.dateFilter == .thisWeek) {
                filters.dateFilter = .thisWeek
            }
            dateRow(label: "This Month", isSelected: filters.dateFilter == .thisMonth) {
                filters.dateFilter = .thisMonth
            }
            dateRow(label: "Custom Range", isSelected: isCustomDateSelected) {
                filters.dateFilter = .custom(start: customStart, end: customEnd)
            }

            if isCustomDateSelected {
                DatePicker("Start", selection: $customStart, displayedComponents: .date)
                    .onChange(of: customStart) {
                        filters.dateFilter = .custom(start: customStart, end: customEnd)
                    }
                DatePicker("End", selection: $customEnd, in: customStart..., displayedComponents: .date)
                    .onChange(of: customEnd) {
                        filters.dateFilter = .custom(start: customStart, end: customEnd)
                    }
            }
        }
    }

    // MARK: Budget section

    private var budgetSection: some View {
        Section("Budget") {
            budgetRow(label: "All Budgets", isSelected: filters.budgetFilter == .all) {
                filters.budgetFilter = .all
            }
            budgetRow(label: "Unassigned", isSelected: filters.budgetFilter == .unassigned) {
                filters.budgetFilter = .unassigned
            }
            ForEach(budgets, id: \.id) { budget in
                budgetRow(
                    label: budget.budgetName,
                    isSelected: filters.budgetFilter == .specific(budgetId: budget.id)
                ) {
                    filters.budgetFilter = .specific(budgetId: budget.id)
                }
            }
        }
    }

    // MARK: Row helpers

    private func dateRow(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label).foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundColor(.blue)
                }
            }
        }
    }

    private func budgetRow(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label).foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    TransactionFilterSheet(filters: .constant(TransactionFilters()), budgets: sampleBudgets)
}
