//
//  EditTransactionView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    let transaction: BudgetTransaction
    
    // Form state
    @State private var title: String
    @State private var amount: Double?
    @State private var date: Date
    @State private var selectedType: TransactionType
    @State private var note: String
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    @State private var showingAddCategory = false
    
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
                Picker("Transaction Type", selection: $selectedType) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                    Text("Transfer").tag(TransactionType.transfer)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .padding(.bottom, 4)
                
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                        .onChange(of: title) { _, newValue in
                            if let predicted = SmartCategorizer.predictCategory(for: newValue, in: modelContext) {
                                withAnimation { self.selectedCategory = predicted }
                            }
                        }
                    
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section("Accounts") {
                    Picker("From Account", selection: $selectedAccount) {
                        Text("Select an account").tag(Account?.none)
                        
                        ForEach(availableAccountsForSelection) { account in
                            // 1. Check if the account is archived
                            let archiveTag = account.isArchived ? " [Archived]" : ""
                            
                            // 2. Safely read the relationship!
                            // If the account has a group, format it. Otherwise, return an empty string.
                            let groupTag = account.group.map { " (\($0.name))" } ?? ""
                            
                            // 3. The Concatenated UI
                            (Text(account.name + archiveTag) + Text(groupTag).foregroundStyle(.secondary))
                                .tag(Optional(account))
                        }
                    }
                    
                    if selectedType == .transfer {
                        Picker("To Account", selection: $selectedToAccount) {
                            Text("Select destination").tag(Account?.none)
                            
                            ForEach(availableToAccountsForSelection) { account in
                                let archiveTag = account.isArchived ? " [Archived]" : ""
                                
                                // Same safe relationship check here
                                let groupTag = account.group.map { " (\($0.name))" } ?? ""
                                
                                // The concatenated grey text trick!
                                (Text(account.name + archiveTag) + Text(" (\(account.type.rawValue))").foregroundStyle(.secondary))
                                    .tag(Optional(account))
                            }
                        }
                    }
                }
                
                if selectedType != .transfer {
                    Section("Category") {
                        HStack {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select a category").tag(Category?.none)
                                ForEach(filteredCategories) { category in
                                    Text(category.name).tag(Optional(category))
                                }
                            }
                            
                            Divider()
                            
                            Button {
                                HapticManager.playImpact(style: .light)
                                showingAddCategory = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.leading, 8)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { updateTransaction() }
                        .disabled(!isFormValid)
                }
            }
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
            .sheet(isPresented: $showingAddCategory) {
                let defaultKind: CategoryKind = (selectedType == .income) ? .income : .expense
                AddCategoryView(defaultKind: defaultKind) { newCategory in
                    self.selectedCategory = newCategory
                }
            }
        }
    }
    
    // MARK: - Logic & Helpers
    
    private var availableAccountsForSelection: [Account] {
        var result = accounts.filter { !$0.isArchived }
        if let selected = selectedAccount, selected.isArchived, !result.contains(where: { $0.id == selected.id }) {
            result.append(selected)
        }
        return result.sorted { $0.name < $1.name }
    }
    
    private var availableToAccountsForSelection: [Account] {
        var result = accounts.filter { !$0.isArchived }
        if let selectedTo = selectedToAccount, selectedTo.isArchived, !result.contains(where: { $0.id == selectedTo.id }) {
            result.append(selectedTo)
        }
        return result.sorted { $0.name < $1.name }
    }
    
    private var filteredCategories: [Category] {
        let kind: CategoryKind = (selectedType == .income) ? .income : .expense
        return categories.filter { $0.kind == kind }
    }
    
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, let amt = amount, amt > 0, selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func updateTransaction() {
        guard isFormValid, let amt = amount else { return }
        
        // Step 1: Reverse the old balance effect.
        TransactionBalanceService.reverse(transaction)
        
        // Step 2: Update the transaction's stored properties.
        transaction.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.amount = amt
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
