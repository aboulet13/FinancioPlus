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
    
    // We bring in the App Group currency preference so we can format text strings!
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"
    
    // 1. FETCH RAW DATA
    @Query(sort: \BudgetTransaction.date, order: .reverse)
    private var transactions: [BudgetTransaction]
    
    // 2. UI STATE
    @State private var transactionToEdit: BudgetTransaction?
    @State private var transactionPendingDeletion: BudgetTransaction?
    
    // Holds the current text typed into the search bar.
    @State private var searchText = ""
    
    // 3. INJECT INTO VIEW MODEL
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
                        searchText.isEmpty ? "No Transactions" : "No Results Found",
                        systemImage: searchText.isEmpty ? "list.bullet.rectangle" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Add your first transaction to start tracking your money." : "Try adjusting your search terms.")
                    )
                } else {
                    List {
                        ForEach(viewModel.groupedTransactions) { group in
                            Section(header: Text(group.monthYear).font(.headline)) {
                                
                                ForEach(group.transactions) { transaction in
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
            .searchable(text: $searchText, prompt: "Search title, category, or note")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    QuickAddMenu()
                }
            }
            .sheet(item: $transactionToEdit) { transaction in
                EditTransactionView(transaction: transaction)
            }
            // CHANGED: Replaced confirmationDialog with native alert & dynamic title
            .alert(
                deleteAlertTitle,
                isPresented: Binding(
                    get: { transactionPendingDeletion != nil },
                    set: { newValue in
                        if newValue == false {
                            transactionPendingDeletion = nil
                        }
                    }
                )
            ) {
                Button("Cancel", role: .cancel) {
                    transactionPendingDeletion = nil
                }
                Button("Delete", role: .destructive) {
                    if let transactionPendingDeletion {
                        deleteTransaction(transactionPendingDeletion)
                        self.transactionPendingDeletion = nil
                    }
                }
            } message: {
                Text("This will remove the transaction and reverse its effect on account balances. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Logic Helpers
    
    // Computes the dynamic alert title with perfectly formatted currency
    private var deleteAlertTitle: String {
        guard let transaction = transactionPendingDeletion else { return "Delete Transaction?" }
        let formattedAmount = transaction.amount.formatted(.currency(code: selectedCurrencyCode))
        return "Delete \(transaction.title) (\(formattedAmount))?"
    }
    
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
                    .foregroundStyle(Color(hex: category.colorHex))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: category.colorHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if transaction.type == .transfer {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "questionmark")
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.15))
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
                MoneyText(amount: transaction.amount)
                    .font(.headline)
                    .foregroundStyle(transaction.type == .expense ? Color.primary : (transaction.type == .transfer ? Color.blue : Color.green))
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
