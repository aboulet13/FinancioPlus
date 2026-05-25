//
//  SettingsView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    @Query private var transactions: [BudgetTransaction]
    @Query private var budgets: [Budget]
    
    // Remember to keep your specific App Group ID here for Widgets!
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"
    
    // Controls the reset alert.
    @State private var isShowingResetAlert = false
    
    // NEW: We observe the Notification Manager
    @State private var notificationManager = NotificationManager.shared
    
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
                // Check authorization status every time we open settings
                notificationManager.checkAuthorizationStatus()
            }
            .alert("Reset All Data?", isPresented: $isShowingResetAlert) {
                
                // Cancel button is clearly visible in an alert.
                Button("Cancel", role: .cancel) { }
                
                // Destructive confirmation button.
                Button("Delete All Data", role: .destructive) {
                    resetAllData()
                    
                    // Reseed default categories so the app isn't completely empty after a wipe!
                    DefaultCategorySeeder.seedCategoriesIfNeeded(
                        in: modelContext,
                        existingCategories: categories
                    )
                }
                
            } message: {
                Text("This will permanently delete all accounts, categories, transactions, and budgets. This action cannot be undone.")
            }
        }
    }
    
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
    }
}

#Preview {
    SettingsView()
}
