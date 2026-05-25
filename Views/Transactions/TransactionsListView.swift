//
//  TransactionsListView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct TransactionsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
<<<<<<< HEAD
    // 1. FETCH RAW DATA
    @Query(sort: \BudgetTransaction.date, order: .reverse)
    private var transactions: [BudgetTransaction]
    
    // 2. UI STATE
    @State private var transactionToEdit: BudgetTransaction?
    @State private var transactionPendingDeletion: BudgetTransaction?
    
    // Holds the current text typed into the search bar.
    @State private var searchText = ""
    
    // 3. INJECT INTO VIEW MODEL
    // We pass both the raw data AND the user's search text.
    private var viewModel: TransactionsViewModel {
        TransactionsViewModel(
            transactions: transactions,
            searchText: searchText
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.groupedTransactions.isEmpty {
                    ContentUnavailableView(
                        // Dynamic message based on whether they are searching or if the app is just empty
                        searchText.isEmpty ? "No Transactions" : "No Results Found",
                        systemImage: searchText.isEmpty ? "list.bullet.rectangle" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Add your first transaction to start tracking your money." : "Try adjusting your search terms.")
                    )
                } else {
                    List {
                        // Loop through our filtered and grouped sections
                        ForEach(viewModel.groupedTransactions) { group in
                            Section(header: Text(group.monthYear).font(.headline)) {
                                
                                ForEach(group.transactions) { transaction in
                                    // NEW: We call our dynamic, colorful row component!
                                    transactionRow(for: transaction)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            transactionToEdit = transaction
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                transactionPendingDeletion = transaction
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
=======
    @Query(sort: \BudgetTransaction.date, order: .reverse)
    private var transactions: [BudgetTransaction]
    
    @State private var isShowingAddTransaction = false
    @State private var selectedTransaction: BudgetTransaction?
    
    // Stores the transaction the user is about to delete.
    @State private var transactionPendingDeletion: BudgetTransaction?
    
    var body: some View {
        NavigationStack {
            Group {
                if transactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions Yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Add your first transaction to start tracking your money.")
                    )
                } else {
                    List {
                        ForEach(transactions) { transaction in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(transaction.title)
                                    .font(.headline)
                                
                                Text(transaction.type.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                MoneyText(amount: transaction.amount)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(amountColor(for: transaction.type))
                                
                                Text(transaction.date, format: .dateTime.day().month().year())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    // Do not delete immediately.
                                    // First store the transaction and ask for confirmation.
                                    transactionPendingDeletion = transaction
                                } label: {
                                    Label("Delete", systemImage: "trash")
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                                }
                            }
                        }
                    }
<<<<<<< HEAD
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Transactions")
            // This single line of code adds a native Apple search bar to the NavigationStack!
            .searchable(text: $searchText, prompt: "Search title, category, or note")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // NEW: Swapped to your global quick add menu!
                    QuickAddMenu()
                }
            }
            .sheet(item: $transactionToEdit) { transaction in
=======
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddTransaction = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTransaction) {
                AddTransactionView()
            }
            .sheet(item: $selectedTransaction) { transaction in
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                EditTransactionView(transaction: transaction)
            }
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: Binding(
                    get: { transactionPendingDeletion != nil },
                    set: { newValue in
                        if newValue == false {
                            transactionPendingDeletion = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Transaction", role: .destructive) {
                    if let transactionPendingDeletion {
                        deleteTransaction(transactionPendingDeletion)
                        self.transactionPendingDeletion = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    transactionPendingDeletion = nil
                }
            } message: {
                Text("This will remove the transaction and reverse its effect on account balances.")
            }
        }
    }
    
<<<<<<< HEAD
    // MARK: - Logic Helpers
    
    private func deleteTransaction(_ transaction: BudgetTransaction) {
        TransactionBalanceService.reverse(transaction)
        modelContext.delete(transaction)
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private func transactionRow(for transaction: BudgetTransaction) -> some View {
        HStack(spacing: 16) {
            // 1. The Dynamic Icon
            if let category = transaction.category {
                Image(systemName: category.iconName)
                    .font(.title3)
                    .foregroundStyle(Color(hex: category.colorHex)) // You nailed this part!
                    .frame(width: 40, height: 40)
                    // Changed to a beautiful 15% tinted transparent background
                    .background(Color(hex: category.colorHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if transaction.type == .transfer {
                // Fallback for Transfers (they don't use categories)
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3)
                    .foregroundStyle(.gray) // Flipped to gray
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.15)) // Transparent gray background
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Fallback for Uncategorized
                Image(systemName: "questionmark")
                    .font(.title3)
                    .foregroundStyle(.gray) // Flipped to gray
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.15)) // Transparent gray background
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // 2. Title & Category Name
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                
                if let category = transaction.category {
                    Text(category.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if transaction.type == .transfer {
                    Text("Transfer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Uncategorized")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 3. Amount & Date
            VStack(alignment: .trailing, spacing: 4) {
                // Formatting the currency safely
                MoneyText(amount: transaction.amount)
                    .font(.headline)
                    .foregroundStyle(transaction.type == .expense ? Color.primary : Color.green)
                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
=======
    private func amountColor(for type: TransactionType) -> Color {
        switch type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
    
    private func deleteTransaction(_ transaction: BudgetTransaction) {
        // Reverse the transaction's balance effect before deleting it.
        TransactionBalanceService.reverse(transaction)
        
        // Delete the transaction itself.
        modelContext.delete(transaction)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    }
}

#Preview {
    TransactionsListView()
}
