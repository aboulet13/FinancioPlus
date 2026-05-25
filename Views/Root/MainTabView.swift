//
//  MainTabView.swift
//  Financio
//
//  Created by Ariane Boulet on 10/04/2026.
//

import SwiftUI

struct MainTabView: View {
    
    // Tap into the global manager
    @Environment(SheetManager.self) private var sheetManager
    
    // Because we need a standard SwiftUI Binding for the .sheet modifier,
    // we create a computed binding that reads and writes to our SheetManager.
    private var sheetBinding: Binding<QuickAddAction?> {
        Binding(
            get: { sheetManager.activeSheet },
            set: { sheetManager.activeSheet = $0 }
        )
    }
    
    var body: some View {
        TabView {
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TransactionsListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
            
            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "chart.pie")
                }
            
            AccountsListView()
                .tabItem {
                    Label("Accounts", systemImage: "creditcard")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        
        // THE CENTRALIZED ROUTER
        // Whenever sheetManager.activeSheet changes, this single block of code handles it!
        .sheet(item: sheetBinding) { action in
            switch action {
            case .transaction:
                AddTransactionView()
            case .account:
                AddAccountView()
            case .budget:
                Text("Add Budget View Goes Here") // Replace with your actual view
            case .savingsGoal:
                Text("Add Savings Goal View Goes Here") // Replace with your actual view
            case .recurringTransaction:
                Text("Add Recurring View Goes Here") // Replace with your actual view
            }
        }
    }
}

#Preview {
    MainTabView()
}
