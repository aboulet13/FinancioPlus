//
//  Financio+App.swift
//  Financio+
//
//  Created by Ariane Boulet on 20/05/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct FinancioApp: App {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Tracks app lifecycle (Active vs Background)
    @Environment(\.scenePhase) private var scenePhase
    
    // Our security engine
    @State private var authManager = BiometricAuthManager()
    
    // Create the global sheet manager
    @State private var sheetManager = SheetManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
                
                if !authManager.isUnlocked {
                    LockScreenView(authManager: authManager)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: authManager.isUnlocked)
            .tint(Color.accentColor)
            
            // Inject global sheet manager into the environment!
            .environment(sheetManager)
            
            // Run this the absolute second the app launches
            .onAppear {
                seedInitialData()
            }
            
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    // 1. Lock the app for security
                    authManager.lockApp()
                    
                    // 2. Sweep the database and schedule notifications!
                    schedulePendingNotifications()
                    
                    // 3. Save the Net Worth history automatically!
                    captureDailySnapshot()
                }
            }
        }
        .modelContainer(SharedSwiftData.sharedContainer)
    }
    
    // MARK: - Initial Setup
    
    @MainActor
    private func seedInitialData() {
        let context = SharedSwiftData.sharedContainer.mainContext
        
        // 1. Fetch any existing categories to see if we even need to seed
        let descriptor = FetchDescriptor<Category>()
        
        if let existingCategories = try? context.fetch(descriptor) {
            // 2. Call your seeder! If categories exist, it does nothing.
            // If it's a fresh install, it populates the database instantly.
            DefaultCategorySeeder.seedCategoriesIfNeeded(
                in: context,
                existingCategories: existingCategories
            )
        }
    }
    
    // MARK: - Notification Sync Logic
    
    // Because we need to fetch from SwiftData outside of a View's @Query,
    // we use the @MainActor attribute and our SharedSwiftData container.
    @MainActor
    private func schedulePendingNotifications() {
        let context = SharedSwiftData.sharedContainer.mainContext
        let descriptor = FetchDescriptor<RecurringTransaction>()
        
        // Safely try to fetch all recurring transactions
        if let recurringTransactions = try? context.fetch(descriptor) {
            
            for transaction in recurringTransactions {
                // If it is active, schedule it (this also overwrites any old notification with the same ID)
                if transaction.isActive {
                    NotificationManager.shared.scheduleNotification(for: transaction)
                } else {
                    // If the user paused it, ensure we cancel any pending alerts
                    NotificationManager.shared.cancelNotification(for: transaction)
                }
            }
        }
    }
    
    // MARK: - Snapshot Engine
        
    @MainActor
    private func captureDailySnapshot() {
        let context = SharedSwiftData.sharedContainer.mainContext
        
        // 1. Fetch all accounts to calculate current reality
        guard let accounts = try? context.fetch(FetchDescriptor<Account>()) else { return }
        
        let totalAssets = accounts.filter { !$0.isArchived && $0.category == .asset }.reduce(0) { $0 + $1.balance }
        let totalLiabilities = accounts.filter { !$0.isArchived && $0.category == .liability }.reduce(0) { $0 + $1.balance }
        let currentNetWorth = totalAssets - totalLiabilities
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // 2. Check if a snapshot for TODAY already exists
        let snapshotDescriptor = FetchDescriptor<NetWorthSnapshot>()
        if let existingSnapshots = try? context.fetch(snapshotDescriptor),
           let todaysSnapshot = existingSnapshots.first(where: { Calendar.current.isDateInToday($0.date) }) {
            
            // It exists! Just update the amount so we don't spam the database
            todaysSnapshot.amount = currentNetWorth
            
        } else {
            
            // It doesn't exist! Create a fresh snapshot for today
            let newSnapshot = NetWorthSnapshot(date: today, amount: currentNetWorth)
            context.insert(newSnapshot)
        }
    }
}
