//
//  DefaultCategorySeeder.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import Foundation
import SwiftData

struct DefaultCategorySeeder {
    
    // Inserts default categories only if no categories exist yet.
    static func seedCategoriesIfNeeded(in modelContext: ModelContext, existingCategories: [Category]) {
        // If categories already exist, do nothing.
        guard existingCategories.isEmpty else { return }
        
        let defaultCategories: [Category] = [
            // Expense categories
            Category(name: "Groceries", kind: .expense, iconName: "cart", colorHex: "#34C759", isSystem: true),
            Category(name: "Rent", kind: .expense, iconName: "house", colorHex: "#FF9500", isSystem: true),
            Category(name: "Transport", kind: .expense, iconName: "car", colorHex: "#007AFF", isSystem: true),
            Category(name: "Utilities", kind: .expense, iconName: "bolt", colorHex: "#FFD60A", isSystem: true),
            Category(name: "Entertainment", kind: .expense, iconName: "gamecontroller", colorHex: "#AF52DE", isSystem: true),
            Category(name: "Dining Out", kind: .expense, iconName: "fork.knife", colorHex: "#FF3B30", isSystem: true),
            
            // Income categories
            Category(name: "Salary", kind: .income, iconName: "banknote", colorHex: "#30D158", isSystem: true),
            Category(name: "Freelance", kind: .income, iconName: "laptopcomputer", colorHex: "#64D2FF", isSystem: true),
            Category(name: "Gift", kind: .income, iconName: "gift", colorHex: "#BF5AF2", isSystem: true)
        ]
        
        for category in defaultCategories {
            modelContext.insert(category)
        }
    }
}
