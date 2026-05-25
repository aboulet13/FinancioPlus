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
    
<<<<<<< HEAD
    // 1. FETCH RAW DATA
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    @Query(sort: \Account.name) private var accounts: [Account]
    
    @State private var isShowingAddAccount = false
    @State private var selectedAccount: Account?
<<<<<<< HEAD
    @State private var accountPendingArchive: Account?
    
    // 2. INJECT INTO VIEW MODEL
    private var viewModel: AccountsViewModel {
        AccountsViewModel(accounts: accounts)
    }
=======
    
    // Stores the account the user is about to archive.
    @State private var accountPendingArchive: Account?
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    
    var body: some View {
        NavigationStack {
            Group {
<<<<<<< HEAD
                if viewModel.activeAccounts.isEmpty && viewModel.archivedAccounts.isEmpty {
=======
                if activeAccounts.isEmpty && archivedAccounts.isEmpty {
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                    ContentUnavailableView(
                        "No Accounts Yet",
                        systemImage: "creditcard",
                        description: Text("Add your first account to start tracking your money.")
                    )
                } else {
                    List {
                        // Active accounts section
<<<<<<< HEAD
                        if !viewModel.activeAccounts.isEmpty {
                            Section("Active Accounts") {
                                ForEach(viewModel.activeAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions {
                                            Button {
=======
                        if !activeAccounts.isEmpty {
                            Section("Active Accounts") {
                                ForEach(activeAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions {
                                            Button {
                                                // Ask for confirmation before archiving.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
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
<<<<<<< HEAD
                        if !viewModel.archivedAccounts.isEmpty {
                            Section("Archived Accounts") {
                                ForEach(viewModel.archivedAccounts) { account in
=======
                        if !archivedAccounts.isEmpty {
                            Section("Archived Accounts") {
                                ForEach(archivedAccounts) { account in
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
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
    
<<<<<<< HEAD
=======
    // Accounts that are still active.
    private var activeAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == false
        }
    }
    
    // Accounts that have been archived.
    private var archivedAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == true
        }
    }
    
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
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
<<<<<<< HEAD
             selectedAccount = account
        }
        // Visually dim archived accounts
        .opacity(account.isArchived ? 0.6 : 1.0)
    }
    
    // UI Interactions that modify the database
=======
            selectedAccount = account
        }
        .opacity(account.isArchived ? 0.6 : 1.0)
    }
    
    // Marks an account as archived.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    private func archiveAccount(_ account: Account) {
        account.isArchived = true
    }
    
<<<<<<< HEAD
=======
    // Marks an account as active again.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    private func unarchiveAccount(_ account: Account) {
        account.isArchived = false
    }
}

#Preview {
    AccountsListView()
}
