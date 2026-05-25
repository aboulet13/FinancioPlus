//
//  Account.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

// NEW: We define the two fundamental types of financial accounts
enum AccountCategory: String, Codable, CaseIterable {
    case asset = "Asset"           // Wealth: Checking, Savings, Investments
    case liability = "Liability"   // Debt: Credit Cards, Loans, Mortgages
}

// Defines the allowed types of accounts in the app.
enum AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case cash = "Cash"
    case investment = "Investment" // NEW: Added for Financio+
    case loan = "Loan"             // NEW: Added for Financio+
}

// The @Model macro tells SwiftData that this class should be stored persistently.
@Model
final class Account {
    
    // A unique identifier for each account.
    var id: UUID
    
    // The name the user gives to the account.
    var name: String
    
    // The kind of account this is.
    var type: AccountType
    
    // The current balance of the account.
    var balance: Double
    
    // Instead of deleting an account permanently, we can mark it as archived.
    var isArchived: Bool
    
    // NEW: The core identifier for Net Worth calculations
    var category: AccountCategory
    
    // The date when the account was created in the app.
    var createdAt: Date
    
    // This initializer defines how to create a new Account object.
    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        balance: Double = 0.0,
        isArchived: Bool = false,
        category: AccountCategory = .asset, // Default to Asset for safety
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.isArchived = isArchived
        self.category = category
        self.createdAt = createdAt
    }
}
