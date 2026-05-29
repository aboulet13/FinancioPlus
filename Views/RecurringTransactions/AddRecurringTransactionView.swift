//
//  AddRecurringTransactionView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct AddRecurringTransactionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var title = ""
    @State private var amount = 0.0
    @State private var selectedType: TransactionType = .expense
    @State private var selectedFrequency: RecurringFrequency = .monthly
    @State private var nextDate = Date()
    @State private var note = ""
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    @State private var isActive = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recurring Rule") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    SmartDecimalField("Amount", value: $amount)

                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(RecurringFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    
                    DatePicker("Next Date", selection: $nextDate, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                    
                    Toggle("Active", isOn: $isActive)
                }
                
                Section("Accounts") {
                    // Source account remains restricted to usable money
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select an account").tag(Account?.none)
                        
                        ForEach(usableActiveAccounts) { account in
                            Text(account.name).tag(Optional(account))
                        }
                    }
                    
                    if selectedType == .transfer {
                        // NEW: Destination account can be ANY active account
                        Picker("To Account", selection: $selectedToAccount) {
                            Text("Select destination").tag(Account?.none)
                            
                            ForEach(activeAccounts) { account in
                                Text(account.name).tag(Optional(account))
                            }
                        }
                    }
                }
                
                if selectedType != .transfer {
                    Section("Category") {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select a category").tag(Category?.none)
                            
                            ForEach(filteredCategories) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Recurring")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecurringTransaction()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedType) { _, newType in
                switch newType {
                case .income:
                    selectedToAccount = nil
                    if selectedCategory?.kind != CategoryKind.income {
                        selectedCategory = nil
                    }
                    
                case .expense:
                    selectedToAccount = nil
                    if selectedCategory?.kind != CategoryKind.expense {
                        selectedCategory = nil
                    }
                    
                case .transfer:
                    selectedCategory = nil
                }
            }
        }
    }
    
    // All active accounts (used for transfers)
    private var activeAccounts: [Account] {
        accounts.filter { !$0.isArchived }
    }
    
    // Only Checking or Credit Card (used for the source of funds)
    private var usableActiveAccounts: [Account] {
        accounts.filter { !$0.isArchived && ($0.type == .checking || $0.type == .creditCard) }
    }
    
    // Filters categories to match the selected transaction type.
    private var filteredCategories: [Category] {
        switch selectedType {
        case .income:
            return categories.filter { category in
                category.kind == CategoryKind.income
            }
        case .expense:
            return categories.filter { category in
                category.kind == CategoryKind.expense
            }
        case .transfer:
            return []
        }
    }
    
    // Validates the recurring transaction form.
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, amount > 0, selectedAccount != nil else {
            return false
        }
        
        switch selectedType {
        case .income:
            return selectedCategory?.kind == CategoryKind.income
            
        case .expense:
            return selectedCategory?.kind == CategoryKind.expense
            
        case .transfer:
            guard let selectedToAccount else { return false }
            return selectedToAccount.id != selectedAccount?.id
        }
    }
    
    // Saves the recurring rule to SwiftData.
    private func saveRecurringTransaction() {
        guard isFormValid else { return }
        
        let newRecurringTransaction = RecurringTransaction(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            type: selectedType,
            frequency: selectedFrequency,
            nextDate: nextDate,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            account: selectedAccount,
            toAccount: selectedType == .transfer ? selectedToAccount : nil,
            category: selectedType == .transfer ? nil : selectedCategory,
            isActive: isActive
        )
        
        modelContext.insert(newRecurringTransaction)
        dismiss()
    }
}

#Preview {
    AddRecurringTransactionView()
}
