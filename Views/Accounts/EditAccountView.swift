//
//  EditAccountView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct EditAccountView: View {
    
    @Environment(\.modelContext) private var modelContext // NEW: Added so we can insert new groups if needed
    @Environment(\.dismiss) private var dismiss
    
    // NEW: Fetch existing groups for smart matching
    @Query private var existingGroups: [AccountGroup]
    
    // 1. THE DATABASE OBJECT
    let account: Account
    
    // 2. TEMPORARY UI STATE
    @State private var name: String
    @State private var type: AccountType
    @State private var balance: Double?
    @State private var category: AccountCategory
    
    // NEW: Group UI State
    @State private var groupName: String
    
    // 3. CUSTOM INITIALIZER
    init(account: Account) {
        self.account = account
        
        // Copy the database values into our temporary form state
        _name = State(initialValue: account.name)
        _type = State(initialValue: account.type)
        _balance = State(initialValue: account.balance)
        _category = State(initialValue: account.category)
        
        // NEW: Pre-fill the group name if this account already belongs to one
        _groupName = State(initialValue: account.group?.name ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // The Category Toggle
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
                
                // NEW: Organization Section
                Section {
                    TextField("e.g. Chase Bank, Fidelity...", text: $groupName)
                } header: {
                    Text("Group Name (Optional)")
                } footer: {
                    Text("Typing a new name will automatically create a group. Typing an existing name will attach this account to it.")
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
        // Step 1: Handle Smart Group matching
        var resolvedGroup: AccountGroup? = nil
        let trimmedGroupName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedGroupName.isEmpty {
            // Check if a group with this name already exists
            if let matchedGroup = existingGroups.first(where: { $0.name.caseInsensitiveCompare(trimmedGroupName) == .orderedSame }) {
                resolvedGroup = matchedGroup
            } else {
                // Create a new group if it doesn't exist
                let newGroup = AccountGroup(name: trimmedGroupName)
                modelContext.insert(newGroup)
                resolvedGroup = newGroup
            }
        }
        
        // Step 2: Write the temporary UI state back into the live database object
        account.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = type
        account.balance = balance ?? 0.0 // positive or negative numbers
        account.category = category    // Save the updated category
        account.group = resolvedGroup  // NEW: Save the resolved group
        
        dismiss() // Close the sheet
    }
}

#Preview {
    Text("EditAccountView Preview")
}
