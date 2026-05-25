//
//  AddAccountView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddAccountView: View {
    
    // Gives access to the SwiftData context and dismiss action
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 1. FORM STATE
    @State private var name = ""
    @State private var type: AccountType = .checking
    @State private var balance: Double? = nil
    
    // NEW: We default to Asset so they don't accidentally create debt!
    @State private var category: AccountCategory = .asset
    
    var body: some View {
        NavigationStack {
            Form {
                // NEW: The Category Toggle
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(AccountCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented) // Gives us that beautiful pill-shaped toggle
                    .padding(.vertical, 4)
                } header: {
                    Text("Is this wealth or debt?")
                }
                
                Section("Account Details") {
                    TextField("Account Name", text: $name)
                    
                    Picker("Account Type", selection: $type) {
                        ForEach(AccountType.allCases, id: \.self) { accType in
                            Text(accType.rawValue).tag(accType)
                        }
                    }
                    
                    TextField("Starting Balance", value: $balance, format: .number)
                        // Changed so the minus sign (-) is available on the keyboard for debt
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                // Cancel button dismisses the sheet without saving.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save button creates and inserts a new Account into SwiftData.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(isFormInvalid)
                }
            }
        }
    }
    
    // 2. LOGIC
    
    // Disable saving if the name field is empty or just spaces.
    private var isFormInvalid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // This function creates a new account and inserts it into SwiftData.
    private func saveAccount() {
        let newAccount = Account(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            balance: balance ?? 0.0,
            category: category // Pass the selected category directly into our SwiftData model!
        )
        
        modelContext.insert(newAccount)
        dismiss()
    }
}

#Preview {
    AddAccountView()
}
