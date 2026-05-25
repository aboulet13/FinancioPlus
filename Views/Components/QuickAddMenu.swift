//
//  QuickAddMenu.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import SwiftUI

struct QuickAddMenu: View {
    
    // Tap into our global manager
    @Environment(SheetManager.self) private var sheetManager
    
    var body: some View {
        Menu {
            Button {
                sheetManager.activeSheet = .transaction
            } label: {
                Label("Add Transaction", systemImage: "dollarsign.circle")
            }
            
            Button {
                sheetManager.activeSheet = .account
            } label: {
                Label("Add Account", systemImage: "building.columns")
            }
            
            Divider()
            
            Button {
                sheetManager.activeSheet = .budget
            } label: {
                Label("Add Budget", systemImage: "chart.bar")
            }
            
            Button {
                sheetManager.activeSheet = .savingsGoal
            } label: {
                Label("Add Savings Goal", systemImage: "target")
            }
            
            Button {
                sheetManager.activeSheet = .recurringTransaction
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
    }
}
