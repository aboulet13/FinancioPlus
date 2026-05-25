//
//  EditAccountView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct EditAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    
<<<<<<< HEAD
    // 1. THE DATABASE OBJECT
    let account: Account
    
    // 2. TEMPORARY UI STATE
    @State private var name: String
    @State private var type: AccountType
    @State private var balance: Double? = nil
    @State private var category: AccountCategory // NEW
    
    // 3. CUSTOM INITIALIZER
    init(account: Account) {
        self.account = account
        
        // Copy the database values into our temporary form state
        _name = State(initialValue: account.name)
        _type = State(initialValue: account.type)
        _balance = State(initialValue: account.balance)
        _category = State(initialValue: account.category)
=======
    // The account being edited.
    let account: Account
    
    // Form state initialized from the account's current values.
    @State private var name: String
    @State private var selectedType: AccountType
    @State private var balance: Double
    
    // Custom initializer to pre-fill the form.
    init(account: Account) {
        self.account = account
        _name = State(initialValue: account.name)
        _selectedType = State(initialValue: account.type)
        _balance = State(initialValue: account.balance)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    }
    
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
                    .pickerStyle(.segmented)
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
                        .keyboardType(.numbersAndPunctuation)
=======
                Section("Account Details") {
                    TextField("Account Name", text: $name)
                    
                    Picker("Account Type", selection: $selectedType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Balance", value: $balance, format: .number)
                        .keyboardType(.decimalPad)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                }
            }
            .navigationTitle("Edit Account")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateAccount()
                    }
<<<<<<< HEAD
                    .disabled(isFormInvalid)
=======
                    .disabled(!isFormValid)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                }
            }
        }
    }
    
<<<<<<< HEAD
    // 4. LOGIC
    private var isFormInvalid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func updateAccount() {
        // Write the temporary UI state back into the live database object
        account.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = type
        account.balance = balance ?? 0 // positive or negative numbers
        account.category = category    // Save the updated category
=======
    // Basic validation for account editing.
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Saves the updated account values.
    private func updateAccount() {
        guard isFormValid else { return }
        
        account.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = selectedType
        account.balance = balance
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        
        dismiss()
    }
}
<<<<<<< HEAD
=======

#Preview {
    Text("EditAccountView Preview")
}
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
