//
//  SettingsView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

<<<<<<< HEAD
//
//  SettingsView.swift
//  Financio
//

=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    @Query private var transactions: [BudgetTransaction]
    @Query private var budgets: [Budget]
    
<<<<<<< HEAD
    // Remember to keep your specific App Group ID here!
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"
    
    @State private var isShowingResetAlert = false
    
    // NEW: We observe the Notification Manager
    @State private var notificationManager = NotificationManager.shared
    
=======
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode = "USD"
    
    // Controls the reset alert.
    @State private var isShowingResetAlert = false
    
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    var body: some View {
        NavigationStack {
            List {
                
                Section("General") {
                    Picker("Currency", selection: $selectedCurrencyCode) {
                        ForEach(CurrencyManager.supportedCurrencies) { currency in
                            Text("\(currency.name) (\(currency.code))")
                                .tag(currency.code)
                        }
                    }
                }
                
<<<<<<< HEAD
                // The Notification Gate
                Section("Notifications") {
                    HStack {
                        Label("Payment Reminders", systemImage: "bell.badge")
                        
                        Spacer()
                        
                        if notificationManager.isAuthorized {
                            Text("Enabled")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Button("Enable") {
                                notificationManager.requestAuthorization()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
                
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
                Section("Customization") {
                    NavigationLink {
                        CategoriesListView()
                    } label: {
                        Label("Manage Categories", systemImage: "tag")
                    }
                    
                    NavigationLink {
                        RecurringTransactionsListView()
                    } label: {
                        Label("Manage Recurring Transactions", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                
                Section("Data Management") {
                    Button(role: .destructive) {
                        isShowingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
<<<<<<< HEAD
                // Check authorization status every time we open settings
                notificationManager.checkAuthorizationStatus()
            }
            .alert("Reset All Data?", isPresented: $isShowingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All Data", role: .destructive) {
                    resetAllData()
                }
=======
                DefaultCategorySeeder.seedCategoriesIfNeeded(
                    in: modelContext,
                    existingCategories: categories
                )
            }
            .alert("Reset All Data?", isPresented: $isShowingResetAlert) {
                
                // Cancel button is clearly visible in an alert.
                Button("Cancel", role: .cancel) { }
                
                // Destructive confirmation button.
                Button("Delete All Data", role: .destructive) {
                    resetAllData()
                }
                
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
            } message: {
                Text("This will permanently delete all accounts, categories, transactions, and budgets. This action cannot be undone.")
            }
        }
    }
    
<<<<<<< HEAD
    private func resetAllData() {
        for transaction in transactions { modelContext.delete(transaction) }
        for budget in budgets { modelContext.delete(budget) }
        for category in categories { modelContext.delete(category) }
        for account in accounts { modelContext.delete(account) }
=======
    // Deletes all stored financial data from SwiftData.
    private func resetAllData() {
        // Delete transactions first because they reference accounts and categories.
        for transaction in transactions {
            modelContext.delete(transaction)
        }
        
        // Delete budgets next because they reference categories.
        for budget in budgets {
            modelContext.delete(budget)
        }
        
        // Delete categories.
        for category in categories {
            modelContext.delete(category)
        }
        
        // Delete accounts last.
        for account in accounts {
            modelContext.delete(account)
        }
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    }
}

#Preview {
    SettingsView()
}
