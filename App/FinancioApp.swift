//
//  FinancioApp.swift
//  Financio
//
//  Created by Ariane Boulet on 10/04/2026.
//

import SwiftUI
import SwiftData

@main
struct FinancioApp: App {
    
    // Tracks whether onboarding has already been completed.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [
            Account.self,
            Category.self,
            BudgetTransaction.self,
            Budget.self,
            RecurringTransaction.self
        ])
    }
}
