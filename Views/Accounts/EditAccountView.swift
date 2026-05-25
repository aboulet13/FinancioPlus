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
    
    // 1. THE DATABASE OBJECT
    let account: Account
    
    // 2. TEMPORARY UI STATE
    @State private var name: String
    @State private var type: AccountType
    @State private var balance: Double?
    @State private var category: AccountCategory
    
    // 3. CUSTOM INITIALIZER
    init(account: Account) {
        self.account = account
        
        // Copy the database values into our temporary form state
        _name = State(initialValue: account.name)
        _type = State(initialValue: account.type)
        _balance = State(initialValue: account.balance)
        _category = State(initialValue: account.category)
    }
    
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
                    .disabled(isFormInvalid)
                }
            }
        }
    }
    
    // 4. LOGIC
    private var isFormInvalid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func updateAccount() {
        // Write the temporary UI state back into the live database object
        account.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = type
        account.balance = balance ?? 0.0 // positive or negative numbers
        account.category = category    // Save the updated category
        
        dismiss() // Close the sheet
    }
}

#Preview {
    Text("EditAccountView Preview")
}
