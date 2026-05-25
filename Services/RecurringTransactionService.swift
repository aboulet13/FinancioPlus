//
//  RecurringTransactionService.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import Foundation
import SwiftData

struct RecurringTransactionService {
    
    // Applies a recurring rule by creating a real transaction,
    // applying its balance effect, and advancing the rule's next date.
    static func applyRecurringTransaction(_ recurring: RecurringTransaction, in modelContext: ModelContext) {
        // Create a real transaction from the recurring rule.
        let newTransaction = BudgetTransaction(
            title: recurring.title,
            amount: recurring.amount,
            date: recurring.nextDate,
            type: recurring.type,
            note: recurring.note,
            account: recurring.account,
            toAccount: recurring.type == .transfer ? recurring.toAccount : nil,
            category: recurring.type == .transfer ? nil : recurring.category
        )
        
        // Apply the balance effect using the shared service.
        TransactionBalanceService.apply(newTransaction)
        
        // Insert the new transaction into SwiftData.
        modelContext.insert(newTransaction)
        
        // Move the recurring rule's next date forward.
        recurring.nextDate = nextDate(after: recurring.nextDate, frequency: recurring.frequency)
    }
    
    // Computes the next scheduled date based on the recurring frequency.
    static func nextDate(after date: Date, frequency: RecurringFrequency) -> Date {
        let calendar = Calendar.current
        
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
    
    // Returns whether the recurring transaction is due today or overdue.
    static func isDue(_ recurring: RecurringTransaction) -> Bool {
        recurring.nextDate <= Date()
    }
}
