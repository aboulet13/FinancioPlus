//
//  SmartCategorizer.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import Foundation
import SwiftData

struct SmartCategorizer {
    
    /// Predicts the most likely category based on a transaction title.
    static func predictCategory(for title: String, in context: ModelContext) -> Category? {
        // Clean the input: " Starbucks " -> "starbucks"
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // We only want to start predicting after they've typed at least 3 letters
        guard cleanTitle.count > 2 else { return nil }
        
        // 1. Fetch all past transactions
        let descriptor = FetchDescriptor<BudgetTransaction>()
        guard let allTransactions = try? context.fetch(descriptor) else { return nil }
        
        // 2. Build a frequency dictionary to count which categories are used for this title
        var categoryCounts: [Category: Int] = [:]
        
        for transaction in allTransactions {
            let pastTitle = transaction.title.lowercased()
            
            // If the past transaction contains what the user is typing...
            if pastTitle.contains(cleanTitle), let category = transaction.category {
                // Add a "vote" for this category
                categoryCounts[category, default: 0] += 1
            }
        }
        
        // 3. Find the category with the highest number of votes
        let mostFrequent = categoryCounts.max { a, b in a.value < b.value }
        
        // Return the winning category, or nil if we have no history for this title
        return mostFrequent?.key
    }
}
