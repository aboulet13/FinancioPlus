//
//  TransactionsViewModel.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftUI

struct TransactionsViewModel {
    
    // 1. RAW INGREDIENTS
    let transactions: [BudgetTransaction]
    let searchText: String // NEW: The view will pass the user's search query here
    
    // A helper struct to represent a "Section" in our SwiftUI List.
    struct TransactionGroup: Identifiable {
        let id = UUID()
        let monthYear: String
        let transactions: [BudgetTransaction]
        let sortDate: Date
    }
    
    // 2. THE FILTERING ALGORITHM (NEW)
    // We compute a filtered array of transactions before we group them.
    private var filteredTransactions: [BudgetTransaction] {
        // If the search bar is empty, just return everything.
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return transactions
        }
        
        // Otherwise, filter the array using localizedCaseInsensitiveContains.
        // This ensures "apple", "APPLE", and "Apple" all match.
        return transactions.filter { transaction in
            let titleMatches = transaction.title.localizedCaseInsensitiveContains(searchText)
            
            // Because category is optional, we provide a default `false` if it is nil.
            let categoryMatches = transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
            
            let noteMatches = transaction.note.localizedCaseInsensitiveContains(searchText)
            
            // If the search text is found in the title, category name, OR note, we keep it.
            return titleMatches || categoryMatches || noteMatches
        }
    }
    
    // 3. COMPUTED DATA (The Grouping Algorithm)
    var groupedTransactions: [TransactionGroup] {
        // Step A: We group the ALREADY FILTERED transactions, not the raw ones.
        let groupedDict = Dictionary(grouping: filteredTransactions) { transaction in
            monthYearString(from: transaction.date)
        }
        
        // Step B: Map the dictionary into our TransactionGroup struct.
        let mappedGroups = groupedDict.map { (key, transactionsInMonth) -> TransactionGroup in
            let representativeDate = transactionsInMonth.first?.date ?? Date()
            let sortedTransactions = transactionsInMonth.sorted { $0.date > $1.date }
            
            return TransactionGroup(
                monthYear: key,
                transactions: sortedTransactions,
                sortDate: representativeDate
            )
        }
        
        // Step C: Sort overarching groups newest to oldest.
        return mappedGroups.sorted { $0.sortDate > $1.sortDate }
    }
    
    // 4. HELPER FUNCTIONS
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func color(for type: TransactionType) -> Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}
