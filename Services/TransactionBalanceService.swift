//
//  TransactionBalanceService.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import Foundation

struct TransactionBalanceService {
    
    // Applies a transaction's balance effect to the related account(s).
    // Use this when creating a new transaction or after editing a transaction.
    static func apply(_ transaction: BudgetTransaction) {
        switch transaction.type {
        case .income:
            // Income increases the selected account balance.
            if let account = transaction.account {
                account.balance += transaction.amount
            }
            
        case .expense:
            // Expense decreases the selected account balance.
            if let account = transaction.account {
                account.balance -= transaction.amount
            }
            
        case .transfer:
            // Transfer moves money from one account to another.
            if let fromAccount = transaction.account {
                fromAccount.balance -= transaction.amount
            }
            
            if let toAccount = transaction.toAccount {
                toAccount.balance += transaction.amount
            }
        }
    }
    
    // Reverses a transaction's balance effect from the related account(s).
    // Use this before deleting a transaction or before changing an existing one.
    static func reverse(_ transaction: BudgetTransaction) {
        switch transaction.type {
        case .income:
            // Reversing income removes that money from the account.
            if let account = transaction.account {
                account.balance -= transaction.amount
            }
            
        case .expense:
            // Reversing expense puts the money back into the account.
            if let account = transaction.account {
                account.balance += transaction.amount
            }
            
        case .transfer:
            // Reversing a transfer restores the money to the source account
            // and removes it from the destination account.
            if let fromAccount = transaction.account {
                fromAccount.balance += transaction.amount
            }
            
            if let toAccount = transaction.toAccount {
                toAccount.balance -= transaction.amount
            }
        }
    }
}
