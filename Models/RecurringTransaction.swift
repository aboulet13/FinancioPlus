//
//  RecurringTransaction.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import Foundation
import SwiftData

// Defines how often a recurring transaction repeats.
enum RecurringFrequency: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// The @Model macro tells SwiftData to persist recurring transaction rules.
@Model
final class RecurringTransaction {
    
    // A unique identifier for each recurring transaction rule.
    var id: UUID
    
    // The visible title of the recurring rule.
    // Example: "Monthly Rent", "Salary", "Netflix"
    var title: String
    
    // The amount associated with the recurring transaction.
    var amount: Double
    
    // The type of transaction this recurring rule generates.
    var type: TransactionType
    
    // How often the rule repeats.
    var frequency: RecurringFrequency
    
    // The next date on which this recurring transaction should be applied.
    var nextDate: Date
    
    // Optional note for extra context.
    var note: String
    
    // The main account used by the recurring transaction.
    var account: Account?
    
    // The destination account, only used for transfers.
    var toAccount: Account?
    
    // The category, used for income and expense transactions.
    var category: Category?
    
    // Indicates whether the recurring rule is currently active.
    // This lets the user pause it without deleting it.
    var isActive: Bool
    
    // Initializer used to create a recurring transaction rule.
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        type: TransactionType,
        frequency: RecurringFrequency,
        nextDate: Date,
        note: String = "",
        account: Account? = nil,
        toAccount: Account? = nil,
        category: Category? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.type = type
        self.frequency = frequency
        self.nextDate = nextDate
        self.note = note
        self.account = account
        self.toAccount = toAccount
        self.category = category
        self.isActive = isActive
    }
}
