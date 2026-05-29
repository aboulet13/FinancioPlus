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
    
    @Query(sort: \AccountGroup.name) private var accountGroups: [AccountGroup]
    
    @State private var isShowingAddAccount = false
    @State private var selectedAccount: Account?
    
    @State private var accountPendingArchive: Account?
    @State private var accountPendingDelete: Account?
    
    // 2. INJECT INTO VIEW MODEL
    private var viewModel: AccountsViewModel {
        AccountsViewModel(accounts: accounts)
    }
    
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
                        // NEW: Net Worth Hero Card placed at the top of the list!
                        netWorthCard
                            .listRowInsets(EdgeInsets()) // Removes default list padding
                            .listRowBackground(Color.clear) // Makes it look like a floating card
                            .listRowSeparator(.hidden) // Removes the list line under the card
                            .padding(.bottom, 8)
                            .padding(.horizontal) // Add horizontal padding back to match inset lists
                        
                        // 1. GROUPED ACTIVE ACCOUNTS
                        ForEach(accountGroups) { group in
                            let groupAccounts = viewModel.activeAccounts.filter { $0.group == group }
                            
                            if !groupAccounts.isEmpty {
                                Section {
                                    ForEach(groupAccounts) { account in
                                        accountRow(for: account)
                                            .swipeActions(edge: .trailing) {
                                                activeSwipeActions(for: account)
                                            }
                                    }
                                } header: {
                                    HStack {
                                        Text(group.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .textCase(nil)
                                        
                                        Spacer()
                                        
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
            .confirmationDialog(
                "Archive this account?",
                isPresented: Binding(
                    get: { accountPendingArchive != nil },
                    set: { newValue in
                        if newValue == false { accountPendingArchive = nil }
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
                Button("Cancel", role: .cancel) { accountPendingArchive = nil }
            } message: {
                Text("Archived accounts are hidden from active lists, excluded from total balance, and unavailable for new transactions.")
            }
            .confirmationDialog(
                "Permanently delete this account?",
                isPresented: Binding(
                    get: { accountPendingDelete != nil },
                    set: { newValue in
                        if newValue == false { accountPendingDelete = nil }
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
                Button("Cancel", role: .cancel) { accountPendingDelete = nil }
            } message: {
                Text("Deleting this account will permanently remove it from your database. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - UI Components
    
    // NEW: The migrated Net Worth Card
    private var netWorthCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Net Worth")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                MoneyText(amount: calculatedNetWorth)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(calculatedNetWorth >= 0 ? Color.primary : Color.red)
            }
            
            Divider()
                        
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Usable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: calculatedUsable)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Savings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: calculatedSavings)
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Invested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: calculatedInvested)
                        .font(.headline)
                        .foregroundStyle(.purple)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Net Worth Calculations
    // Brought over from the Dashboard to keep this view perfectly standalone
    
    private var calculatedNetWorth: Double {
        let active = accounts.filter { !$0.isArchived }
        let assets = active.filter { $0.category == .asset }.reduce(0) { $0 + $1.balance }
        let liabilities = abs(active.filter { $0.category == .liability }.reduce(0) { $0 + $1.balance })
        return assets - liabilities
    }
    
    private var calculatedUsable: Double {
        accounts.filter { !$0.isArchived && ($0.type == .checking || $0.type == .cash) }.reduce(0) { $0 + $1.balance }
    }
    
    private var calculatedSavings: Double {
        accounts.filter { !$0.isArchived && $0.type == .savings }.reduce(0) { $0 + $1.balance }
    }
    
    private var calculatedInvested: Double {
        accounts.filter { !$0.isArchived && $0.type == .investment }.reduce(0) { $0 + $1.balance }
    }
    
    // MARK: - Row & Swipe Actions
    
    @ViewBuilder
    private func activeSwipeActions(for account: Account) -> some View {
        Button {
            accountPendingArchive = account
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        .tint(.orange)
        
        Button(role: .destructive) {
            accountPendingDelete = account
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
    @ViewBuilder
    private func archivedSwipeActions(for account: Account) -> some View {
        Button {
            unarchiveAccount(account)
        } label: {
            Label("Unarchive", systemImage: "arrow.uturn.backward")
        }
        .tint(.blue)
        
        Button(role: .destructive) {
            accountPendingDelete = account
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
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
        .opacity(account.isArchived ? 0.6 : 1.0)
    }
    
    // MARK: - Database Actions
    
    private func archiveAccount(_ account: Account) { account.isArchived = true }
    private func unarchiveAccount(_ account: Account) { account.isArchived = false }
    private func deleteAccount(_ account: Account) { modelContext.delete(account) }
}

#Preview {
    AccountsListView()
}
