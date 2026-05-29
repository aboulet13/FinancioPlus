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
    
    // Fetch categories to populate the category picker.
    @Query(sort: \Category.name) private var categories: [Category]
    
    // Fetch all budgets so we can prevent duplicates.
    @Query private var budgets: [Budget]
    
    // The budget being edited.
    let budget: Budget
    
    // Form state
    @State private var selectedCategory: Category?
    @State private var plannedAmount: Double
    
    // Initialize form fields with the existing budget values.
    init(budget: Budget) {
        self.budget = budget
        _selectedCategory = State(initialValue: budget.category)
        _plannedAmount = State(initialValue: budget.plannedAmount)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Details") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select a category").tag(Category?.none)
                        
                        ForEach(expenseCategories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                    
                    SmartDecimalField("Planned Amount", value: $plannedAmount)
                }
                
                // Show a warning if editing would create a duplicate budget.
                if selectedCategory != nil && duplicateBudgetExists {
                    Section {
                        Text("Another budget already exists for this category this month.")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Budget")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateBudget()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Only expense categories should be budgeted.
    private var expenseCategories: [Category] {
        categories.filter { category in
            category.kind == CategoryKind.expense
        }
    }
    
    // Checks whether another budget already exists for the same
    // category, month, and year.
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
        guard isFormValid else { return }
        guard let selectedCategory else { return }
        
        budget.category = selectedCategory
        budget.plannedAmount = plannedAmount
        
        dismiss()
    }
}

#Preview {
    Text("EditBudgetView Preview")
}
