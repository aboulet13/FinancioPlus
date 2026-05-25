//
//  EditTransactionView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    
    // NEW: Needed for the SmartCategorizer to read past transactions
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all accounts and categories from SwiftData.
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    // The existing transaction that we are editing.
    let transaction: BudgetTransaction
    
    // Form state initialized from the existing transaction.
    @State private var title: String
    @State private var amount: Double?
    @State private var date: Date
    @State private var selectedType: TransactionType
    @State private var note: String
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    
    // NEW: Trigger for the inline Add Category sheet
    @State private var showingAddCategory = false
    
    // Custom initializer to pre-fill the form with the transaction's current values.
    init(transaction: BudgetTransaction) {
        self.transaction = transaction
        _title = State(initialValue: transaction.title)
        _amount = State(initialValue: transaction.amount)
        _date = State(initialValue: transaction.date)
        _selectedType = State(initialValue: transaction.type)
        _note = State(initialValue: transaction.note)
        _selectedAccount = State(initialValue: transaction.account)
        _selectedToAccount = State(initialValue: transaction.toAccount)
        _selectedCategory = State(initialValue: transaction.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {

                // Segmented control moved to the top, matching AddTransactionView
                Picker("Transaction Type", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .padding(.bottom, 4)
                
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                        // The Smart Prediction Trigger
                        .onChange(of: title) { oldValue, newValue in
                            if let predictedCategory = SmartCategorizer.predictCategory(for: newValue, in: modelContext) {
                                withAnimation {
                                    self.selectedCategory = predictedCategory
                                }
                            }
                        }
                    
                    // (Old Type picker removed from here)
                    
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section("Accounts") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select an account").tag(Account?.none)
                        
                        ForEach(availableAccountsForSelection) { account in
                            Text(accountDisplayName(account)).tag(account as Account?)
                        }
                    }
                    
                    // Only show destination account picker for transfers.
                    if selectedType == .transfer {
                        Picker("To Account", selection: $selectedToAccount) {
                            Text("Select destination").tag(Account?.none)
                            
                            ForEach(availableToAccountsForSelection) { account in
                                Text(accountDisplayName(account)).tag(account as Account?)
                            }
                        }
                    }
                }
                
                // Only show category picker for income and expense.
                if selectedType != .transfer {
                    Section("Category") {
                        HStack {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select a category").tag(Category?.none)
                                
                                ForEach(filteredCategories) { category in
                                    Text(category.name).tag(category as Category?)
                                }
                            }
                            
                            Divider()
                            
                            // The Quick-Add Button
                            Button {
                                // Add haptic feedback so it feels physical
                                HapticManager.playImpact(style: .light)
                                showingAddCategory = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.leading, 8)
                            }
                            // CRITICAL: Prevents the whole row from acting as a button!
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateTransaction()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedType) { _, newType in
                switch newType {
                case .income:
                    // Income does not use a destination account.
                    selectedToAccount = nil
                    
                    // Clear the category if it is not a valid income category.
                    if selectedCategory?.kind != CategoryKind.income {
                        selectedCategory = nil
                    }
                    
                case .expense:
                    // Expense does not use a destination account.
                    selectedToAccount = nil
                    
                    // Clear the category if it is not a valid expense category.
                    if selectedCategory?.kind != CategoryKind.expense {
                        selectedCategory = nil
                    }
                    
                case .transfer:
                    selectedCategory = nil
                }
            }
            // Tells the category sheet what type of category to default to
            .sheet(isPresented: $showingAddCategory) {
                let defaultKind: CategoryKind = (selectedType == .income) ? .income : .expense
                
                AddCategoryView(defaultKind: defaultKind) { newCategory in
                    self.selectedCategory = newCategory
                }
            }
        }
    }
    
    // MARK: - Logic & Helpers
    
    // Main account picker options:
    // all active accounts, plus the currently selected one if it is archived.
    private var availableAccountsForSelection: [Account] {
        var result = accounts.filter { account in
            account.isArchived == false
        }
        
        if let selectedAccount,
           selectedAccount.isArchived,
           result.contains(where: { account in
               account.id == selectedAccount.id
           }) == false {
            result.append(selectedAccount)
        }
        
        return result.sorted { first, second in
            first.name < second.name
        }
    }
    
    // Destination account picker options:
    // all active accounts, plus the currently selected destination account if it is archived.
    private var availableToAccountsForSelection: [Account] {
        var result = accounts.filter { account in
            account.isArchived == false
        }
        
        if let selectedToAccount,
           selectedToAccount.isArchived,
           result.contains(where: { account in
               account.id == selectedToAccount.id
           }) == false {
            result.append(selectedToAccount)
        }
        
        return result.sorted { first, second in
            first.name < second.name
        }
    }
    
    // Filters categories so the user only sees categories
    // matching the chosen transaction type.
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
    
    // Basic validation for the form.
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, (amount ?? 0) > 0, selectedAccount != nil else {
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
    
    // Adds a label for archived accounts when they appear in edit pickers.
    private func accountDisplayName(_ account: Account) -> String {
        if account.isArchived {
            return "\(account.name) (Archived)"
        } else {
            return account.name
        }
    }
    
    // Updates the transaction by reversing the old balance effects,
    // changing the stored values, then applying the new effects.
    private func updateTransaction() {
        guard isFormValid else { return }
        
        // Step 1: Reverse the old balance effect.
        TransactionBalanceService.reverse(transaction)
        
        // Step 2: Update the transaction's stored properties.
        transaction.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.amount = amount ?? 0
        transaction.date = date
        transaction.type = selectedType
        transaction.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.account = selectedAccount
        transaction.toAccount = selectedType == .transfer ? selectedToAccount : nil
        transaction.category = selectedType == .transfer ? nil : selectedCategory
        
        // Step 3: Apply the new balance effect.
        TransactionBalanceService.apply(transaction)
        
        dismiss()
    }
}

#Preview {
    Text("EditTransactionView Preview")
}
