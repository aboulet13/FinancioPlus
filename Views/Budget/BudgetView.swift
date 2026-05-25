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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Month Navigation Header
                HStack {
                    Button {
                        goToPreviousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(viewModel.monthYearTitle) // Purely driven by ViewModel
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
                    if viewModel.selectedMonthBudgets.isEmpty {
                        ContentUnavailableView(
                            "No Budgets Yet",
                            systemImage: "chart.pie",
                            description: Text("Add your first monthly budget to start planning your spending.")
                        )
                    } else {
                        List {
                            ForEach(viewModel.selectedMonthBudgets) { budget in
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
                                            MoneyText(amount: viewModel.spentAmount(for: budget))
                                                .font(.subheadline)
                                                .foregroundStyle(.red)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Remaining")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            MoneyText(amount: viewModel.remainingAmount(for: budget))
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(viewModel.remainingAmount(for: budget) >= 0 ? .green : .red)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ProgressView(value: viewModel.progressValue(for: budget))
                                            .tint(viewModel.progressColor(for: budget))
                                        
                                        Text(viewModel.progressText(for: budget))
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
                
                Button("Cancel", role: .cancel) {
                    budgetPendingDeletion = nil
                }
            } message: {
                Text("This will permanently remove the budget entry for the selected month.")
            }
        }
    }
    
    // UI State modification stays in the View layer
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
