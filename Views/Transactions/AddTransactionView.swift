//
//  AddTransactionView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    
    // Gives access to the SwiftData context so we can insert transactions.
    @Environment(\.modelContext) private var modelContext
    
    // Lets us dismiss the sheet after saving or canceling.
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all accounts so the user can select one.
    @Query(sort: \Account.name) private var accounts: [Account]
    
    // Fetch all categories so the user can select one when needed.
    @Query(sort: \Category.name) private var categories: [Category]
    
<<<<<<< HEAD
    // Trigger for the inline Add Category sheet
    @State private var showingAddCategory = false
    
    // Form state properties
    @State private var title = ""
    @State private var amount: Double? = nil
=======
    // Form state properties
    @State private var title = ""
    @State private var amount = 0.0
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    @State private var date = Date()
    @State private var selectedType: TransactionType = .expense
    @State private var note = ""
    
    // Selected related models
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    
    // Filter accounts to select from active accounts only
    private var activeAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == false
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
<<<<<<< HEAD
                // The user needs to be able to choose the transaction type!
                Picker("Transaction Type", selection: $selectedType) {
                    // Assuming your TransactionType enum has raw values or you can hardcode the strings:
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                    Text("Transfer").tag(TransactionType.transfer)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear) // Makes the segmented control look native outside a section
                .padding(.bottom, 4)
            
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                    
                    // The Smart Prediction Trigger
                    .onChange(of: title) { oldValue, newValue in
                        // Ask our engine if it recognizes this word
                        if let predictedCategory = SmartCategorizer.predictCategory(for: newValue, in: modelContext) {
                            withAnimation {
                                self.selectedCategory = predictedCategory
                            }
=======
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                        }
                    }
                    
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
<<<<<<< HEAD
                                
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                Section("Accounts") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select an account").tag(Account?.none)
                        ForEach(activeAccounts) { account in
<<<<<<< HEAD
                            // EXPLICIT CAST: Fixes SwiftUI picker bugs
                            Text(account.name).tag(account as Account?)
=======
                            Text(account.name).tag(Optional(account))
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                        }
                    }
                    
                    // Only show destination account picker for transfers.
                    if selectedType == .transfer {
                        Picker("To Account", selection: $selectedToAccount) {
                            Text("Select destination").tag(Account?.none)
                            ForEach(activeAccounts) { account in
                                Text(account.name).tag(Optional(account))
                            }
                        }
                    }
                }
                
<<<<<<< HEAD
                // Only show categories if it's an Income or Expense
                if selectedType != .transfer {
                    Section("Categorization") {
                        HStack {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select Category").tag(Category?(nil))
                                // FIX: Changed 'categories' to 'filteredCategories'
                                ForEach(filteredCategories) { category in
                                    // EXPLICIT CAST: Fixes SwiftUI picker bugs
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
=======
                // Only show category picker for income and expense.
                if selectedType != .transfer {
                    Section("Category") {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select a category").tag(Category?.none)
                            ForEach(filteredCategories) { category in
                                Text(category.name).tag(Optional(category))
                            }
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                        }
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isFormValid)
                }
            }
<<<<<<< HEAD
            
            // Clears stale memory when changing transaction type
            .onChange(of: selectedType) { _, newType in
                switch newType {
                case .income:
                    selectedToAccount = nil
                    if selectedCategory?.kind != .income { selectedCategory = nil }
                case .expense:
                    selectedToAccount = nil
                    if selectedCategory?.kind != .expense { selectedCategory = nil }
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
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        }
    }
    
    // Filters categories so the user only sees categories
    // that match the chosen transaction type.
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
        
<<<<<<< HEAD
        // We use (amount ?? 0) to say "If amount is nil, treat it as 0 for this check"
        guard !trimmedTitle.isEmpty, (amount ?? 0) > 0, selectedAccount != nil else {
=======
        // Title must not be empty and amount must be greater than zero.
        guard !trimmedTitle.isEmpty, amount > 0, selectedAccount != nil else {
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
            return false
        }
        
        switch selectedType {
        case .income, .expense:
            // Income and expense should have a category.
            return selectedCategory != nil
            
        case .transfer:
            // Transfers need a destination account that is different from the source account.
            guard let selectedToAccount else { return false }
            return selectedToAccount.id != selectedAccount?.id
        }
    }
    
    // Creates and saves the transaction, then updates account balances.
    private func saveTransaction() {
        guard let selectedAccount else { return }
        
        let newTransaction = BudgetTransaction(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
<<<<<<< HEAD
            amount: amount ?? 0.0,
=======
            amount: amount,
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
            date: date,
            type: selectedType,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            account: selectedAccount,
            toAccount: selectedType == .transfer ? selectedToAccount : nil,
            category: selectedType == .transfer ? nil : selectedCategory
        )
        
        // Apply the balance effect of the new transaction.
        TransactionBalanceService.apply(newTransaction)
        
        // Insert the transaction into SwiftData.
        modelContext.insert(newTransaction)
        
<<<<<<< HEAD
        // NEW: Play a satisfying "Success" vibration!
        HapticManager.playNotification(type: .success)
        
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        // Close the sheet.
        dismiss()
    }
}

#Preview {
    AddTransactionView()
}
