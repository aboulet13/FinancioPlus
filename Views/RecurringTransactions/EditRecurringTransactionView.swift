//
//  EditRecurringTransactionView.swift
//  Financio
//
//  Created by Ariane on 26/05/2026.
//

import SwiftUI
import SwiftData

struct EditRecurringTransactionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    let recurringTransaction: RecurringTransaction
    
    @State private var title: String
    @State private var amount: Double
    @State private var selectedType: TransactionType
    @State private var selectedFrequency: RecurringFrequency
    @State private var nextDate: Date
    @State private var note: String
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    @State private var isActive: Bool
    
    init(recurringTransaction: RecurringTransaction) {
        self.recurringTransaction = recurringTransaction
        _title = State(initialValue: recurringTransaction.title)
        _amount = State(initialValue: recurringTransaction.amount)
        _selectedType = State(initialValue: recurringTransaction.type)
        _selectedFrequency = State(initialValue: recurringTransaction.frequency)
        _nextDate = State(initialValue: recurringTransaction.nextDate)
        _note = State(initialValue: recurringTransaction.note ?? "")
        _selectedAccount = State(initialValue: recurringTransaction.account)
        _selectedToAccount = State(initialValue: recurringTransaction.toAccount)
        _selectedCategory = State(initialValue: recurringTransaction.category)
        _isActive = State(initialValue: recurringTransaction.isActive)
    }
    
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
                    
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    
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
            .navigationTitle("Edit Recurring")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { updateRecurringTransaction() }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedType) { _, newType in
                switch newType {
                case .income:
                    selectedToAccount = nil
                    if selectedCategory?.kind != CategoryKind.income { selectedCategory = nil }
                case .expense:
                    selectedToAccount = nil
                    if selectedCategory?.kind != CategoryKind.expense { selectedCategory = nil }
                case .transfer:
                    selectedCategory = nil
                }
            }
        }
    }
    
    // NEW: All active accounts (used for transfers)
    private var activeAccounts: [Account] {
        accounts.filter { !$0.isArchived }
    }
    
    private var usableActiveAccounts: [Account] {
        accounts.filter { !$0.isArchived && ($0.type == .checking || $0.type == .creditCard) }
    }
    
    private var filteredCategories: [Category] {
        switch selectedType {
        case .income: return categories.filter { $0.kind == CategoryKind.income }
        case .expense: return categories.filter { $0.kind == CategoryKind.expense }
        case .transfer: return []
        }
    }
    
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, amount > 0, selectedAccount != nil else { return false }
        
        switch selectedType {
        case .income: return selectedCategory?.kind == CategoryKind.income
        case .expense: return selectedCategory?.kind == CategoryKind.expense
        case .transfer:
            guard let selectedToAccount else { return false }
            return selectedToAccount.id != selectedAccount?.id
        }
    }
    
    private func updateRecurringTransaction() {
        guard isFormValid else { return }
        recurringTransaction.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        recurringTransaction.amount = amount
        recurringTransaction.type = selectedType
        recurringTransaction.frequency = selectedFrequency
        recurringTransaction.nextDate = nextDate
        recurringTransaction.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        recurringTransaction.account = selectedAccount
        recurringTransaction.toAccount = selectedType == .transfer ? selectedToAccount : nil
        recurringTransaction.category = selectedType == .transfer ? nil : selectedCategory
        recurringTransaction.isActive = isActive
        dismiss()
    }
}
