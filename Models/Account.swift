//
//  Account.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

<<<<<<< HEAD
// NEW: We define the two fundamental types of financial accounts
enum AccountCategory: String, Codable, CaseIterable {
    case asset = "Asset"           // Wealth: Checking, Savings, Investments
    case liability = "Liability"   // Debt: Credit Cards, Loans, Mortgages
}

// Ensure your existing AccountType enum is still here
enum AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case cash = "Cash"
    case investment = "Investment" // NEW: Added for Financio+
    case loan = "Loan"             // NEW: Added for Financio+
}

@Model
final class Account {
    var id: UUID
    var name: String
    var type: AccountType
    var balance: Double
    var isArchived: Bool
    
    // NEW: The core identifier for Net Worth calculations
    var category: AccountCategory
    
=======
// This enum defines the allowed types of accounts in the app.
// Using an enum is safer than using plain text strings,
// because Swift can restrict the possible values.
enum AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case cash = "Cash"
    case creditCard = "Credit Card"
}

// The @Model macro tells SwiftData that this class should be stored persistently.
// In other words, objects of this class can be saved to the app's local database.
@Model
final class Account {
    
    // A unique identifier for each account.
    // We use UUID so every account is guaranteed to be distinguishable.
    var id: UUID
    
    // The name the user gives to the account.
    // Example: "Main Checking", "Emergency Savings"
    var name: String
    
    // The kind of account this is.
    // We use the enum above so the user must choose from valid account types.
    var type: AccountType
    
    // The current balance of the account.
    // We use Double because money values can include decimals.
    // Example: 1250.75
    var balance: Double
    
    // The date when the account was created in the app.
    // This can be useful later for sorting or analytics.
    var createdAt: Date
    
    // Instead of deleting an account permanently,
    // we can mark it as archived and hide it from normal views.
    var isArchived: Bool
    
    // This initializer defines how to create a new Account object.
    // We provide default values for some properties to make object creation easier.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        balance: Double = 0.0,
<<<<<<< HEAD
        isArchived: Bool = false,
        category: AccountCategory = .asset // Default to Asset for safety
=======
        createdAt: Date = Date(),
        isArchived: Bool = false
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
<<<<<<< HEAD
        self.isArchived = isArchived
        self.category = category
=======
        self.createdAt = createdAt
        self.isArchived = isArchived
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    }
}
