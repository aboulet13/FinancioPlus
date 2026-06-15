//
//  Budget.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftData

@Model
final class Budget {
    
    var id: UUID
    var month: Int
    var year: Int
    var plannedAmount: Double
    var category: Category?
    
    // Determines if this budget should auto-duplicate into the next month
    var isRecurring: Bool
    
    init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        plannedAmount: Double,
        category: Category? = nil,
        isRecurring: Bool = false // Default to false
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.plannedAmount = plannedAmount
        self.category = category
        self.isRecurring = isRecurring
    }
}
