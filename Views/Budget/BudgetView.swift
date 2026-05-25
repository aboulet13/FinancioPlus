//
//  BudgetView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct BudgetView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var budgets: [Budget]
    @Query private var transactions: [BudgetTransaction]
    
    @State private var isShowingAddBudget = false
    @State private var selectedBudget: Budget?
<<<<<<< HEAD
    @State private var budgetPendingDeletion: Budget?
    
    // UI State: Tracks which month the user is currently looking at.
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    // 1. INJECT THE VIEW MODEL
    // We instantiate the ViewModel on the fly, passing in our raw data and current UI state.
    private var viewModel: BudgetViewModel {
        BudgetViewModel(
            budgets: budgets,
            transactions: transactions,
            selectedMonth: selectedMonth,
            selectedYear: selectedYear
        )
    }
    
=======
    
    // Stores the budget the user is about to delete.
    @State private var budgetPendingDeletion: Budget?
    
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
<<<<<<< HEAD
                // Month Navigation Header
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                HStack {
                    Button {
                        goToPreviousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
<<<<<<< HEAD
                    Text(viewModel.monthYearTitle) // Pulled from ViewModel
=======
                    Text(monthYearTitle)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        goToNextMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                Group {
<<<<<<< HEAD
                    if viewModel.selectedMonthBudgets.isEmpty { // Pulled from ViewModel
=======
                    if selectedMonthBudgets.isEmpty {
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                        ContentUnavailableView(
                            "No Budgets Yet",
                            systemImage: "chart.pie",
                            description: Text("Add your first monthly budget to start planning your spending.")
                        )
                    } else {
                        List {
<<<<<<< HEAD
                            ForEach(viewModel.selectedMonthBudgets) { budget in
=======
                            ForEach(selectedMonthBudgets) { budget in
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    Text(budget.category?.name ?? "Unknown Category")
                                        .font(.headline)
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Planned")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            MoneyText(amount: budget.plannedAmount)
                                                .font(.subheadline)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .center, spacing: 4) {
                                            Text("Spent")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
<<<<<<< HEAD
                                            MoneyText(amount: viewModel.spentAmount(for: budget)) // ViewModel
=======
                                            MoneyText(amount: spentAmount(for: budget))
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                                                .font(.subheadline)
                                                .foregroundStyle(.red)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Remaining")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
<<<<<<< HEAD
                                            MoneyText(amount: viewModel.remainingAmount(for: budget)) // ViewModel
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(viewModel.remainingAmount(for: budget) >= 0 ? .green : .red)
=======
                                            MoneyText(amount: remainingAmount(for: budget))
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(remainingAmount(for: budget) >= 0 ? .green : .red)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
<<<<<<< HEAD
                                        ProgressView(value: viewModel.progressValue(for: budget)) // ViewModel
                                            .tint(viewModel.progressColor(for: budget)) // ViewModel
                                        
                                        Text(viewModel.progressText(for: budget)) // ViewModel
=======
                                        ProgressView(value: progressValue(for: budget))
                                            .tint(progressColor(for: budget))
                                        
                                        Text(progressText(for: budget))
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedBudget = budget
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        budgetPendingDeletion = budget
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddBudget = true
                    } label: {
                        Label("Add Budget", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddBudget) {
                AddBudgetView(month: selectedMonth, year: selectedYear)
            }
            .sheet(item: $selectedBudget) { budget in
                EditBudgetView(budget: budget)
            }
            .confirmationDialog(
                "Delete this budget?",
                isPresented: Binding(
                    get: { budgetPendingDeletion != nil },
                    set: { newValue in
                        if newValue == false {
                            budgetPendingDeletion = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Budget", role: .destructive) {
                    if let budgetPendingDeletion {
                        deleteBudget(budgetPendingDeletion)
                        self.budgetPendingDeletion = nil
                    }
                }
<<<<<<< HEAD
=======
                
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                Button("Cancel", role: .cancel) {
                    budgetPendingDeletion = nil
                }
            } message: {
                Text("This will permanently remove the budget entry for the selected month.")
            }
        }
    }
    
<<<<<<< HEAD
    // UI State modification stays in the View layer
=======
    private var selectedMonthBudgets: [Budget] {
        budgets.filter { budget in
            budget.month == selectedMonth && budget.year == selectedYear
        }
    }
    
    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        
        return formatter.string(from: date)
    }
    
    private func spentAmount(for budget: Budget) -> Double {
        guard let category = budget.category else { return 0 }
        
        return transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.category?.id == category.id &&
                isInSelectedMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    private func remainingAmount(for budget: Budget) -> Double {
        budget.plannedAmount - spentAmount(for: budget)
    }
    
    private func progressValue(for budget: Budget) -> Double {
        guard budget.plannedAmount > 0 else { return 0 }
        
        let ratio = spentAmount(for: budget) / budget.plannedAmount
        return min(ratio, 1.0)
    }
    
    private func progressText(for budget: Budget) -> String {
        guard budget.plannedAmount > 0 else { return "No budget set" }
        
        let percentage = (spentAmount(for: budget) / budget.plannedAmount) * 100
        return String(format: "%.0f%% of budget used", percentage)
    }
    
    private func progressColor(for budget: Budget) -> Color {
        remainingAmount(for: budget) >= 0 ? .blue : .red
    }
    
    private func isInSelectedMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return month == selectedMonth && year == selectedYear
    }
    
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    private func goToPreviousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }
    
    private func goToNextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }
    
    private func deleteBudget(_ budget: Budget) {
        modelContext.delete(budget)
    }
}

#Preview {
    BudgetView()
}
