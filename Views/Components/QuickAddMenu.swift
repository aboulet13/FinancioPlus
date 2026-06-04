//
//  QuickAddMenu.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import SwiftUI

struct QuickAddMenu: View {
    
    // 1. LOCAL STATE TOGGLES (Self-Contained Routing)
    @State private var showingAddTransaction = false
    @State private var showingAddAccount = false
    @State private var showingAddBudget = false
    @State private var showingAddSavingsGoal = false
    @State private var showingAddRecurring = false
    
    // We need these because AddBudgetView requires a time context!
    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        Menu {
            Button {
                HapticManager.playImpact(style: .light)
                showingAddTransaction = true
            } label: {
                Label("Add Transaction", systemImage: "dollarsign.circle")
            }
            
            Button {
                HapticManager.playImpact(style: .light)
                showingAddAccount = true
            } label: {
                Label("Add Account", systemImage: "building.columns")
            }
            
            Divider() // Visual separator
            
            Button {
                HapticManager.playImpact(style: .light)
                showingAddBudget = true
            } label: {
                Label("Add Budget", systemImage: "chart.bar")
            }
            
            Button {
                HapticManager.playImpact(style: .light)
                showingAddSavingsGoal = true
            } label: {
                Label("Add Savings Goal", systemImage: "target")
            }
            
            Button {
                HapticManager.playImpact(style: .light)
                showingAddRecurring = true
            } label: {
                Label("Add Recurring Bill", systemImage: "arrow.2.squarepath")
            }
            
        } label: {
            // The actual button the user sees in the top right corner
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical) // Gives it a premium translucent look
        }
        
        // 2. THE SHEET LISTENERS
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
        .sheet(isPresented: $showingAddBudget) {
            // Injecting the date context safely!
            AddBudgetView(month: currentMonth, year: currentYear)
        }
        .sheet(isPresented: $showingAddSavingsGoal) {
            AddSavingsGoalView()
        }
        .sheet(isPresented: $showingAddRecurring) {
            AddRecurringTransactionView()
        }
    }
}

#Preview {
    QuickAddMenu()
}
