//
//  SharedSwiftData.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//


import Foundation
import SwiftData

// A centralized manager to ensure both the Main App and the Widget
// are reading from the exact same database file in the App Group.
@MainActor
struct SharedSwiftData {
    
    // We create a single, shared container to be used everywhere.
    static let sharedContainer: ModelContainer = {
        do {
            // 1. Define the models we want to store
            let schema = Schema([
                Account.self,
                Category.self,
                BudgetTransaction.self,
                Budget.self,
                RecurringTransaction.self,
                SavingsGoals.self
            ])
            
            // 2. Point to the shared App Group folder
            // REPLACE "group.com.yourname.Financio" with the exact App Group ID you created!
            let appGroupIdentifier = "group.com.ariane.Financio"
            
            guard let sharedURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
                fatalError("Failed to find App Group container. Did you enable App Groups in Signing & Capabilities?")
            }
            
            // 3. Define the exact file path for the database inside the shared folder
            let databaseURL = sharedURL.appendingPathComponent("FinancioShared.sqlite")
            let configuration = ModelConfiguration(url: databaseURL)
            
            // 4. Initialize and return the container
            return try ModelContainer(for: schema, configurations: [configuration])
            
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error.localizedDescription)")
        }
    }()
}
