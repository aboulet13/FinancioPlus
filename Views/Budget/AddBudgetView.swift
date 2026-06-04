//
//  AddBudgetView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddBudgetView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var budgets: [Budget]
    
    let month: Int
    let year: Int
    
    @State private var selectedCategory: Category?
    @State private var plannedAmount = 0.0 // Restored for SmartDecimalField
    
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
                    
                    // Restored your custom component!
                    SmartDecimalField("Planned Amount", value: $plannedAmount)
                }
                
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
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveBudget() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var expenseCategories: [Category] {
        categories.filter { $0.kind == CategoryKind.expense }
    }
    
    private var duplicateBudgetExists: Bool {
        guard let selectedCategory else { return false }
        
        return budgets.contains { budget in
            budget.month == month &&
            budget.year == year &&
            budget.category?.id == selectedCategory.id
        }
    }
    
    private var isFormValid: Bool {
        selectedCategory != nil &&
        plannedAmount > 0 &&
        !duplicateBudgetExists
    }
    
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
