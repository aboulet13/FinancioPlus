//
//  EditBudgetView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct EditBudgetView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var budgets: [Budget]
    
    @Query(sort: \BudgetTransaction.date, order: .reverse) private var allTransactions: [BudgetTransaction]
    
    let budget: Budget
    
    @State private var selectedCategory: Category?
    @State private var plannedAmount: Double
    @State private var isRecurring: Bool
    
    @State private var isShowingAddCategory = false
    
    init(budget: Budget) {
        self.budget = budget
        _selectedCategory = State(initialValue: budget.category)
        _plannedAmount = State(initialValue: budget.plannedAmount)
        _isRecurring = State(initialValue: budget.isRecurring)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Details") {
                    
                    // NEW: The side-by-side layout
                    HStack {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select a category").tag(Category?.none)
                            
                            ForEach(expenseCategories) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                        
                        Button {
                            isShowingAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.bold())
                        }
                        // CRITICAL: Prevents the button's tap area from overriding the Picker
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                    }
                    
                    SmartDecimalField("Planned Amount", value: $plannedAmount)
                    
                    Toggle("Repeat Monthly", isOn: $isRecurring)
                }
                
                if selectedCategory != nil && duplicateBudgetExists {
                    Section {
                        Text("Another budget already exists for this category this month.")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Budget Activity (\(budgetTransactions.count))") {
                    if budgetTransactions.isEmpty {
                        Text("No spending in this category for this month.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(budgetTransactions) { transaction in
                            HStack(spacing: 12) {
                                if let category = transaction.category {
                                    Image(systemName: category.iconName)
                                        .font(.subheadline)
                                        .foregroundStyle(Color(hex: category.colorHex))
                                        .frame(width: 36, height: 36)
                                        .background(Color(hex: category.colorHex).opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.title)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    
                                    Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                MoneyText(amount: transaction.amount)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.primary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Edit Budget")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { updateBudget() }
                        .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $isShowingAddCategory) {
                AddCategoryView(onSave: { newCategory in
                    // Instantly select the newly created category!
                    self.selectedCategory = newCategory
                })
            }
        }
    }
    
    // MARK: - Logic & Helpers
    
    private var budgetTransactions: [BudgetTransaction] {
        guard let categoryId = selectedCategory?.id else { return [] }
        
        let calendar = Calendar.current
        
        return allTransactions.filter { transaction in
            guard transaction.type == .expense else { return false }
            guard transaction.category?.id == categoryId else { return false }
            
            let tMonth = calendar.component(.month, from: transaction.date)
            let tYear = calendar.component(.year, from: transaction.date)
            
            return tMonth == budget.month && tYear == budget.year
        }
    }
    
    private var expenseCategories: [Category] {
        categories.filter { $0.kind == CategoryKind.expense }
    }
    
    private var duplicateBudgetExists: Bool {
        guard let selectedCategory else { return false }
        
        return budgets.contains { existingBudget in
            existingBudget.id != budget.id &&
            existingBudget.month == budget.month &&
            existingBudget.year == budget.year &&
            existingBudget.category?.id == selectedCategory.id
        }
    }
    
    private var isFormValid: Bool {
        selectedCategory != nil &&
        plannedAmount > 0 &&
        !duplicateBudgetExists
    }
    
    private func updateBudget() {
        guard isFormValid, let selectedCategory else { return }
        
        budget.category = selectedCategory
        budget.plannedAmount = plannedAmount
        budget.isRecurring = isRecurring
        
        dismiss()
    }
}
