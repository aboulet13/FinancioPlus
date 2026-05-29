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
    
    // NEW: Fetch existing groups so we can check if the user's typed group already exists
    @Query private var existingGroups: [AccountGroup]
    
    // 1. FORM STATE
    @State private var name = ""
    @State private var type: AccountType = .checking
    @State private var balance: Double? = nil
    
    // We default to Asset so they don't accidentally create debt!
    @State private var category: AccountCategory = .asset
    
    // NEW: The state for our smart group field
    @State private var groupName = ""
    
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
                    
                    SmartDecimalField("Starting Balance", value: $balance, allowNegative: true)
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
        // Step 1: Handle the Smart Group matching
        var resolvedGroup: AccountGroup? = nil
        let trimmedGroupName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedGroupName.isEmpty {
            // Check if a group with this exact name already exists (ignoring upper/lower case)
            if let matchedGroup = existingGroups.first(where: { $0.name.caseInsensitiveCompare(trimmedGroupName) == .orderedSame }) {
                resolvedGroup = matchedGroup
            } else {
                // If it doesn't exist, create it and save it to the database
                let newGroup = AccountGroup(name: trimmedGroupName)
                modelContext.insert(newGroup)
                resolvedGroup = newGroup
            }
        }
        
        // Step 2: Create the Account and attach the resolved group
        let newAccount = Account(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            balance: balance ?? 0.0,
            category: category,
            group: resolvedGroup // NEW: Pass the resolved group
        )
        
        modelContext.insert(newAccount)
        dismiss()
    }
}

#Preview {
    AddAccountView()
}
