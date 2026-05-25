//
//  AddAccountView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddAccountView: View {
    
<<<<<<< HEAD
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 1. FORM STATE
    @State private var name = ""
    @State private var type: AccountType = .checking
    @State private var balance: Double? = nil
    
    // NEW: We default to Asset so they don't accidentally create debt!
    @State private var category: AccountCategory = .asset
=======
    // Gives access to the SwiftData context so we can save a new account.
    @Environment(\.modelContext) private var modelContext
    
    // Gives us access to the dismiss action so we can close the sheet.
    @Environment(\.dismiss) private var dismiss
    
    // Form field for the account name.
    @State private var name = ""
    
    // Form field for the selected account type.
    @State private var selectedType: AccountType = .checking
    
    // Form field for the starting balance.
    @State private var balance = 0.0
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    
    var body: some View {
        NavigationStack {
            Form {
                
<<<<<<< HEAD
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
                    
                    TextField("Current Balance", value: $balance, format: .number)
                        // Changed so the minus sign (-) is available on the keyboard
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            .navigationTitle("New Account")
            .toolbar {
=======
                Section("Account Details") {
                    
                    // Text field for the account name.
                    TextField("Account Name", text: $name)
                    
                    // Picker for selecting the account type.
                    Picker("Account Type", selection: $selectedType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    // Field for entering the starting balance.
                    // The currency format helps the user enter money values.
                    TextField("Starting Balance", value: $balance, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Account")
            .toolbar {
                
                // Cancel button dismisses the sheet without saving.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
<<<<<<< HEAD
=======
                // Save button creates and inserts a new Account into SwiftData.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveAccount()
                    }
<<<<<<< HEAD
                    .disabled(isFormInvalid)
=======
                    // Disable saving if the name field is empty.
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                }
            }
        }
    }
    
<<<<<<< HEAD
    // 2. LOGIC
    private var isFormInvalid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveAccount() {
        let newAccount = Account(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            balance: balance ?? 0,
            // Pass the selected category directly into our SwiftData model!
            category: category
        )
        
        modelContext.insert(newAccount)
=======
    // This function creates a new account and inserts it into SwiftData.
    private func saveAccount() {
        let newAccount = Account(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType,
            balance: balance
        )
        
        // Insert the new account into the model context.
        modelContext.insert(newAccount)
        
        // Close the sheet after saving.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        dismiss()
    }
}

#Preview {
    AddAccountView()
}
