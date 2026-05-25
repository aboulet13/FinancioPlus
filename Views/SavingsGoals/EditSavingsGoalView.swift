//
//  EditSavingsGoalView.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//


import SwiftUI
import SwiftData

struct EditSavingsGoalView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // The database object we are editing
    let goal: SavingsGoals
    
    // 1. LOCAL FORM STATE
    @State private var title: String
    @State private var targetAmount: Double
    @State private var currentAmount: Double
    @State private var hasDeadline: Bool
    @State private var targetDate: Date
    @State private var iconName: String
    
    // 2. CUSTOM INITIALIZER
    init(goal: SavingsGoals) {
        self.goal = goal
        
        // We use State(initialValue:) to copy the database data into our temporary UI state.
        _title = State(initialValue: goal.title)
        _targetAmount = State(initialValue: goal.targetAmount)
        _currentAmount = State(initialValue: goal.currentAmount)
        
        // Check if a date exists to set our toggle properly
        _hasDeadline = State(initialValue: goal.targetDate != nil)
        _targetDate = State(initialValue: goal.targetDate ?? Date())
        
        _iconName = State(initialValue: goal.iconName)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name", text: $title)
                    
                    TextField("Target Amount", value: $targetAmount, format: .number)
                        .keyboardType(.decimalPad)
                    
                    TextField("Currently Saved", value: $currentAmount, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section("Timeline") {
                    Toggle("Set a Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker(
                            "Target Date",
                            selection: $targetDate,
                            displayedComponents: .date
                        )
                    }
                }
                
                Section("Appearance") {
                    TextField("SF Symbol Name", text: $iconName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Edit Goal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateGoal()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // 3. LOGIC
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && targetAmount > 0
    }
    
    private func updateGoal() {
        guard isFormValid else { return }
        
        // Write the temporary UI state back into the live database object
        goal.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.targetAmount = targetAmount
        goal.currentAmount = currentAmount
        goal.targetDate = hasDeadline ? targetDate : nil
        goal.iconName = iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "star.fill" : iconName
        
        dismiss()
    }
}

#Preview {
    Text("EditSavingsGoal Preview")
}
