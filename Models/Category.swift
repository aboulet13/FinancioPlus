//
//  Category.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

// This enum defines whether a category is used for income or expenses.
// This helps us keep financial data organized correctly.
enum CategoryKind: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
}

// The @Model macro tells SwiftData that Category objects
// should be stored in the local persistent database.
@Model
final class Category {
    
    // A unique identifier for each category.
    // We use UUID so each category can be uniquely recognized.
    var id: UUID
    
    // The visible name of the category.
    // Example: "Groceries", "Rent", "Salary"
    var name: String
    
    // Indicates whether the category belongs to income or expense transactions.
    var kind: CategoryKind
    
    // Stores the name of an SF Symbol icon.
    // Example: "cart", "house", "dollarsign.circle"
    var iconName: String
    
    // Stores a color as a hex string.
    // Example: "#34C759" for green, "#FF3B30" for red
    // We store text here because Color itself is not ideal as stored model data.
    var colorHex: String
    
    // Indicates whether this category is a built-in system category
    // or one created by the user.
    var isSystem: Bool
    
    // Initializer used to create a new category.
    init(
        id: UUID = UUID(),
        name: String,
        kind: CategoryKind,
        iconName: String = "tag",
        colorHex: String = "#007AFF",
        isSystem: Bool = false
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.iconName = iconName
        self.colorHex = colorHex
        self.isSystem = isSystem
    }
}
