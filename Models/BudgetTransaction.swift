//
//  Transaction.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

// This enum defines the three kinds of transactions
// our budgeting app supports.
enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"
}

// The @Model macro tells SwiftData to store Transaction objects persistently.
@Model
final class BudgetTransaction {
    
    // A unique identifier for each transaction.
    var id: UUID
    
    // A short title that describes the transaction.
    // Example: "Weekly groceries", "Paycheck", "Move to savings"
    var title: String
    
    // The amount of money involved in the transaction.
    // We store this as a positive value and interpret it using the transaction type.
    var amount: Double
    
    // The date when the transaction happened.
    var date: Date
    
    // The kind of transaction: income, expense, or transfer.
    var type: TransactionType
    
    // An optional note for extra details.
    // Example: "Bought food for the week"
    var note: String
    
    // The main account related to the transaction.
    // For an expense: money leaves this account.
    // For an income: money enters this account.
    // For a transfer: money leaves this account.
    var account: Account?
    
    // The destination account for transfers.
    // This is only needed when type == .transfer.
    var toAccount: Account?
    
    // The category for the transaction.
    // This is useful for income and expense transactions.
    // For transfers, category may be nil.
    var category: Category?
    
    // Initializer used to create a new transaction.
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        type: TransactionType,
        note: String = "",
        account: Account? = nil,
        toAccount: Account? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.type = type
        self.note = note
        self.account = account
        self.toAccount = toAccount
        self.category = category
    }
}
