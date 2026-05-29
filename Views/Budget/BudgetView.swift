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
                        withAnimation { goToPreviousMonth() }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                    
                    Spacer()
                    
                    Text(viewModel.monthYearTitle) // Purely driven by ViewModel
                        .font(.headline)
                        .bold()
                        // This modifier makes the text transition smoothly when changing months
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Button {
                        withAnimation { goToNextMonth() }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary, Color(.systemGray5))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                
                Group {
                    if viewModel.selectedMonthBudgets.isEmpty {
                        ContentUnavailableView(
                            "No Budgets Set",
                            systemImage: "chart.pie",
                            description: Text("Add your first monthly budget to start planning your spending.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.selectedMonthBudgets) { budget in
                                    budgetCard(for: budget)
                                        .onTapGesture {
                                            selectedBudget = budget
                                        }
                                        // We use contextMenu here since we aren't using a standard List anymore
                                        .contextMenu {
                                            Button {
                                                selectedBudget = budget
                                            } label: {
                                                Label("Edit Budget", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                budgetPendingDeletion = budget
                                            } label: {
                                                Label("Delete Budget", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                        .background(Color(.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle("Budgets")
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
    
    // MARK: - UI Components
    
    // Upgraded Budget Card Design
    @ViewBuilder
    private func budgetCard(for budget: Budget) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top Row: Category Name & Icon
            HStack {
                // If you have icon/color data in the Category, you can add the colored icon here!
                if let category = budget.category {
                    Image(systemName: category.iconName)
                        .foregroundStyle(Color(hex: category.colorHex))
                        .frame(width: 28, height: 28)
                        .background(Color(hex: category.colorHex).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Text(budget.category?.name ?? "Unknown Category")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundStyle(.tertiary)
            }
            
            // Middle Row: Financial Breakdown
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Planned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: budget.plannedAmount)
                        .font(.subheadline)
                        .bold()
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
            
            // Bottom Row: Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                        
                        Capsule()
                            .fill(viewModel.progressColor(for: budget))
                            .frame(width: geo.size.width * CGFloat(viewModel.progressValue(for: budget)))
                    }
                }
                .frame(height: 8)
                
                Text(viewModel.progressText(for: budget))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Logic
    
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
