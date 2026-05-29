//
//  AddTransactionView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 1. DATA FETCHING
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    // 2. FORM STATE
    @State private var title = ""
    @State private var amount: Double? = nil
    @State private var date = Date()
    @State private var selectedType: TransactionType = .expense
    @State private var note = ""
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var selectedCategory: Category?
    @State private var showingAddCategory = false
    
    private var activeAccounts: [Account] {
        accounts.filter { !$0.isArchived }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Segmented Type Picker
                Picker("Transaction Type", selection: $selectedType) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                    Text("Transfer").tag(TransactionType.transfer)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                        .onChange(of: title) { _, newValue in
                            if let predicted = SmartCategorizer.predictCategory(for: newValue, in: modelContext) {
                                withAnimation { self.selectedCategory = predicted }
                            }
                        }
                    
                    SmartDecimalField("Amount", value: $amount)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section("Accounts") {
                    Picker("From Account", selection: $selectedAccount) {
                        Text("Select account").tag(Account?.none)
                        ForEach(activeAccounts) { account in
                            Text(account.name).tag(Optional(account))
                        }
                    }
                    
                    if selectedType == .transfer {
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
                        HStack {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select category").tag(Category?.none)
                                ForEach(filteredCategories) { category in
                                    Text(category.name).tag(Optional(category))
                                }
                            }
                            
                            Button {
                                HapticManager.playImpact(style: .light)
                                showingAddCategory = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedType) { _, newType in
                // Clean up invalid selections when toggling types
                if newType == .transfer { selectedCategory = nil }
            }
            .sheet(isPresented: $showingAddCategory) {
                let defaultKind: CategoryKind = (selectedType == .income) ? .income : .expense
                AddCategoryView(defaultKind: defaultKind) { newCategory in
                    self.selectedCategory = newCategory
                }
            }
        }
    }
    
    // 3. LOGIC
    private var filteredCategories: [Category] {
        let kind: CategoryKind = (selectedType == .income) ? .income : .expense
        return categories.filter { $0.kind == kind }
    }
    
    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, let amount = amount, amount > 0, selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func saveTransaction() {
        guard let selectedAccount, let amount = amount else { return }
        
        let newTransaction = BudgetTransaction(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            date: date,
            type: selectedType,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            account: selectedAccount,
            toAccount: selectedType == .transfer ? selectedToAccount : nil,
            category: selectedType == .transfer ? nil : selectedCategory
        )
        
        TransactionBalanceService.apply(newTransaction)
        modelContext.insert(newTransaction)
        HapticManager.playNotification(type: .success)
        dismiss()
    }
}
