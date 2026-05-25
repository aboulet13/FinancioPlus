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
                                }
                            }
                        }
                    }
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
        }
}

#Preview {
    TransactionsListView()
}
