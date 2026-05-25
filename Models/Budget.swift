//
//  Budget.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

// The @Model macro tells SwiftData that Budget objects
// should be stored persistently in the local database.
@Model
final class Budget {
    
    // A unique identifier for each budget record.
    var id: UUID
    
    // The month this budget applies to.
    // Example: 1 for January, 12 for December
    var month: Int
    
    // The year this budget applies to.
    // Example: 2026
    var year: Int
    
    // The amount the user plans to spend for this category
    // during the specified month and year.
    var plannedAmount: Double
    
    // The category this budget belongs to.
    // Example: Groceries, Rent, Entertainment
    var category: Category?
    
    // Initializer used to create a new budget.
    init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        plannedAmount: Double,
        category: Category? = nil
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.plannedAmount = plannedAmount
        self.category = category
    }
}
