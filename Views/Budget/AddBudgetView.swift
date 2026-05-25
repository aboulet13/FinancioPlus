//
//  AddBudgetView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddBudgetView: View {
    
    // SwiftData context for saving new budgets.
    @Environment(\.modelContext) private var modelContext
    
    // Dismiss action to close the sheet.
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all categories from SwiftData.
    @Query(sort: \Category.name) private var categories: [Category]
    
    // Fetch all budgets so we can check for duplicates.
    @Query private var budgets: [Budget]
    
    // The month and year are passed in from BudgetView.
    let month: Int
    let year: Int
    
    // Form state
    @State private var selectedCategory: Category?
    @State private var plannedAmount = 0.0
    
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
                    
                    TextField("Planned Amount", value: $plannedAmount, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                // Show a warning if the selected category already has
                // a budget for the same month and year.
                if selectedCategory != nil && duplicateBudgetExists {
                    Section {
                        Text("A budget already exists for this category this month.")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Returns only expense categories, because budgets are mainly for spending.
    private var expenseCategories: [Category] {
        categories.filter { category in
            category.kind == CategoryKind.expense
        }
    }
    
    // Returns true if a budget already exists for the selected category
    // in the same month and year.
    private var duplicateBudgetExists: Bool {
        guard let selectedCategory else { return false }
        
        return budgets.contains { budget in
            budget.month == month &&
            budget.year == year &&
            budget.category?.id == selectedCategory.id
        }
    }
    
    // Determines whether the form can be saved.
    private var isFormValid: Bool {
        selectedCategory != nil &&
        plannedAmount > 0 &&
        !duplicateBudgetExists
    }
    
    // Creates and saves a new budget entry.
    private func saveBudget() {
        guard let selectedCategory else { return }
        
        let newBudget = Budget(
            month: month,
            year: year,
            plannedAmount: plannedAmount,
            category: selectedCategory
        )
        
        modelContext.insert(newBudget)
        dismiss()
    }
}

#Preview {
    AddBudgetView(month: 4, year: 2026)
}
