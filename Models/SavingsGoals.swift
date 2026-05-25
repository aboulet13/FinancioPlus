//
//  SavingsGoals.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//

import Foundation
import SwiftData

// The @Model macro tells SwiftData to create a new database table for this class.
@Model
final class SavingsGoals {
    
    // Unique identifier for the database
    var id: UUID
    
    // The name of the goal (e.g., "Emergency Fund", "New MacBook")
    var title: String
    
    // The total amount the user wants to save
    var targetAmount: Double
    
    // How much money is currently allocated to this goal
    var currentAmount: Double
    
    // An optional deadline to reach the goal.
    // It is optional (?) because a user might just want to save without a strict timeline.
    var targetDate: Date?
    
    // UI customization to make the app look playful and personal
    var iconName: String
    var colorHex: String
    
    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Double,
        currentAmount: Double = 0.0, // Defaults to 0 when starting a new goal
        targetDate: Date? = nil,
        iconName: String = "star.fill",
        colorHex: String = "#FFD60A" // Default yellow color
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.iconName = iconName
        self.colorHex = colorHex
    }
}
