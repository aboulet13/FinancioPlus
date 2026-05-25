//
//  AddSavingsGoalView.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//


import SwiftUI
import SwiftData

struct AddSavingsGoalView: View {
    
    // 1. ENVIRONMENT
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 2. FORM STATE
    @State private var title = ""
    @State private var targetAmount: Double = 0.0
    @State private var currentAmount: Double = 0.0
    
    // UI State for the optional date
    @State private var hasDeadline = false
    @State private var targetDate = Date()
    
    // Customization (We keep it simple with text fields for now)
    @State private var iconName = "star.fill"
    @State private var colorHex = "#007AFF" // Default Blue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name (e.g. Vacation)", text: $title)
                    
                    TextField("Target Amount", value: $targetAmount, format: .number)
                        .keyboardType(.decimalPad)
                    
                    TextField("Already Saved (Optional)", value: $currentAmount, format: .number)
                        .keyboardType(.decimalPad)
                }
                
                Section("Timeline") {
                    Toggle("Set a Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker(
                            "Target Date",
                            selection: $targetDate,
                            in: Date()..., // Prevents selecting dates in the past!
                            displayedComponents: .date
                        )
                    }
                }
                
                Section("Appearance") {
                    TextField("SF Symbol Name (e.g. car, airplane)", text: $iconName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    HStack {
                        Image(systemName: iconName.isEmpty ? "star.fill" : iconName)
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        
                        Text("Preview")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // 3. LOGIC
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // Must have a name and a target greater than 0
        return !trimmedTitle.isEmpty && targetAmount > 0
    }
    
    private func saveGoal() {
        let newGoal = SavingsGoals(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            // If the toggle is off, we pass nil. If on, we pass the selected date.
            targetDate: hasDeadline ? targetDate : nil,
            iconName: iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "star.fill" : iconName,
            colorHex: colorHex
        )
        
        // Save to SwiftData and close the sheet
        modelContext.insert(newGoal)
        dismiss()
    }
}

#Preview {
    AddSavingsGoalView()
}
