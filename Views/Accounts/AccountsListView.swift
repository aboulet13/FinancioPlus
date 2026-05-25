//
//  AccountsListView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AccountsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. FETCH RAW DATA
    @Query(sort: \Account.name) private var accounts: [Account]
    
    @State private var isShowingAddAccount = false
    @State private var selectedAccount: Account?
    
    // Stores the account the user is about to archive.
    @State private var accountPendingArchive: Account?
    
    // 2. INJECT INTO VIEW MODEL
    private var viewModel: AccountsViewModel {
        AccountsViewModel(accounts: accounts)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.activeAccounts.isEmpty && viewModel.archivedAccounts.isEmpty {
                    ContentUnavailableView(
                        "No Accounts Yet",
                        systemImage: "creditcard",
                        description: Text("Add your first account to start tracking your money.")
                    )
                } else {
                    List {
                        // Active accounts section
                        if !viewModel.activeAccounts.isEmpty {
                            Section("Active Accounts") {
                                ForEach(viewModel.activeAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions {
                                            Button {
                                                // Ask for confirmation before archiving.
                                                accountPendingArchive = account
                                            } label: {
                                                Label("Archive", systemImage: "archivebox")
                                            }
                                            .tint(.orange)
                                        }
                                }
                            }
                        }
                        
                        // Archived accounts section
                        if !viewModel.archivedAccounts.isEmpty {
                            Section("Archived Accounts") {
                                ForEach(viewModel.archivedAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions {
                                            Button {
                                                unarchiveAccount(account)
                                            } label: {
                                                Label("Unarchive", systemImage: "arrow.uturn.backward")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddAccount = true
                    } label: {
                        Label("Add Account", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddAccount) {
                AddAccountView()
            }
            .sheet(item: $selectedAccount) { account in
                EditAccountView(account: account)
            }
            .confirmationDialog(
                "Archive this account?",
                isPresented: Binding(
                    get: { accountPendingArchive != nil },
                    set: { newValue in
                        if newValue == false {
                            accountPendingArchive = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Archive Account", role: .destructive) {
                    if let accountPendingArchive {
                        archiveAccount(accountPendingArchive)
                        self.accountPendingArchive = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    accountPendingArchive = nil
                }
            } message: {
                Text("Archived accounts are hidden from active lists, excluded from total balance, and unavailable for new transactions.")
            }
        }
    }
    
    // Reusable row view for an account.
    @ViewBuilder
    private func accountRow(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(account.name)
                .font(.headline)
            
            Text(account.type.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            MoneyText(amount: account.balance)
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedAccount = account
        }
        // Visually dim archived accounts
        .opacity(account.isArchived ? 0.6 : 1.0)
    }
    
    // UI Interactions that modify the database
    
    // Marks an account as archived.
    private func archiveAccount(_ account: Account) {
        account.isArchived = true
    }
    
    // Marks an account as active again.
    private func unarchiveAccount(_ account: Account) {
        account.isArchived = false
    }
}

#Preview {
    AccountsListView()
}
