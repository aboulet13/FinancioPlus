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
    
    // Fetch our account groups
    @Query(sort: \AccountGroup.name) private var accountGroups: [AccountGroup]
    
    @State private var isShowingAddAccount = false
    @State private var selectedAccount: Account?
    
    // Stores the account the user is about to archive.
    @State private var accountPendingArchive: Account?
    
    // Stores the account the user is about to permanently delete.
    @State private var accountPendingDelete: Account?
    
    // 2. INJECT INTO VIEW MODEL
    private var viewModel: AccountsViewModel {
        AccountsViewModel(accounts: accounts)
    }
    
    // Helper to find active accounts that don't belong to any group
    private var ungroupedActiveAccounts: [Account] {
        viewModel.activeAccounts.filter { $0.group == nil }
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
                        // 1. GROUPED ACTIVE ACCOUNTS
                        ForEach(accountGroups) { group in
                            // Only get active accounts for this specific group
                            let groupAccounts = viewModel.activeAccounts.filter { $0.group == group }
                            
                            // Only show the group if it has active accounts
                            if !groupAccounts.isEmpty {
                                Section {
                                    ForEach(groupAccounts) { account in
                                        accountRow(for: account)
                                            .swipeActions(edge: .trailing) {
                                                activeSwipeActions(for: account)
                                            }
                                    }
                                } header: {
                                    // Custom Header showing Group Name and Total Balance
                                    HStack {
                                        Text(group.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .textCase(nil) // Prevents iOS from forcing all-caps on section headers
                                        
                                        Spacer()
                                        
                                        // Calculate sum of only the active accounts in this group
                                        let groupTotal = groupAccounts.reduce(0) { $0 + $1.balance }
                                        MoneyText(amount: groupTotal)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                        
                        // 2. UNGROUPED ACTIVE ACCOUNTS
                        if !ungroupedActiveAccounts.isEmpty {
                            Section {
                                ForEach(ungroupedActiveAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions(edge: .trailing) {
                                            activeSwipeActions(for: account)
                                        }
                                }
                            } header: {
                                Text("Other Accounts")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .textCase(nil)
                            }
                        }
                        
                        // 3. ARCHIVED ACCOUNTS
                        // We leave these flat (ungrouped) since they are just historical records
                        if !viewModel.archivedAccounts.isEmpty {
                            Section("Archived Accounts") {
                                ForEach(viewModel.archivedAccounts) { account in
                                    accountRow(for: account)
                                        .swipeActions(edge: .trailing) {
                                            archivedSwipeActions(for: account)
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
            // MARK: - Confirmation Dialogs
            // ARCHIVE DIALOG
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
            // DELETE DIALOG
            .confirmationDialog(
                "Permanently delete this account?",
                isPresented: Binding(
                    get: { accountPendingDelete != nil },
                    set: { newValue in
                        if newValue == false {
                            accountPendingDelete = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    if let accountPendingDelete {
                        deleteAccount(accountPendingDelete)
                        self.accountPendingDelete = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    accountPendingDelete = nil
                }
            } message: {
                Text("Deleting this account will permanently remove it from your database. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - UI Components
    
    // Extracted swipe actions for Active accounts
    @ViewBuilder
    private func activeSwipeActions(for account: Account) -> some View {
        // 1st Button (Outermost / Full-Swipe action): Archive
        Button {
            accountPendingArchive = account
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        .tint(.orange)
        
        // 2nd Button (Innermost): Delete
        Button(role: .destructive) {
            accountPendingDelete = account
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red) // Explicitly forcing the red color
    }
    
    // Extracted swipe actions for Archived accounts
    @ViewBuilder
    private func archivedSwipeActions(for account: Account) -> some View {
        // 1st Button (Outermost / Full-Swipe action): Unarchive
        Button {
            unarchiveAccount(account)
        } label: {
            Label("Unarchive", systemImage: "arrow.uturn.backward")
        }
        .tint(.blue)
        
        // 2nd Button (Innermost): Delete
        Button(role: .destructive) {
            accountPendingDelete = account
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red) // Explicitly forcing the red color
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
    
    // MARK: - UI Interactions that modify the database
    
    private func archiveAccount(_ account: Account) {
        account.isArchived = true
    }
    
    private func unarchiveAccount(_ account: Account) {
        account.isArchived = false
    }
    
    private func deleteAccount(_ account: Account) {
        modelContext.delete(account)
    }
}

#Preview {
    AccountsListView()
}
