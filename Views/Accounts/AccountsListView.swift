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
    
    // NEW: Fetch our account groups
    @Query(sort: \AccountGroup.name) private var accountGroups: [AccountGroup]
    
    @State private var isShowingAddAccount = false
    @State private var selectedAccount: Account?
    
    // Stores the account the user is about to archive.
    @State private var accountPendingArchive: Account?
    
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
                                            .swipeActions {
                                                archiveSwipeButton(for: account)
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
                                        .swipeActions {
                                            archiveSwipeButton(for: account)
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
    
    // MARK: - UI Components
    
    // Extracted the archive swipe button to avoid repeating code in the groups
    @ViewBuilder
    private func archiveSwipeButton(for account: Account) -> some View {
        Button {
            // Ask for confirmation before archiving.
            accountPendingArchive = account
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        .tint(.orange)
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
