//
//  SavingsGoalViewModel.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//


import Foundation
import SwiftUI

// Transforms raw SavingsGoal data into formatted metrics for the UI.
struct SavingsGoalsViewModel {
    
    // 1. RAW INGREDIENTS
    let goals: [SavingsGoals]
    
    // 2. COMPUTED DATA / MATH LOGIC
    
    // Returns how much money is still needed to finish the goal
    func remainingAmount(for goal: SavingsGoals) -> Double {
        let remaining = goal.targetAmount - goal.currentAmount
        // We use max() to ensure we never return a negative number if they over-save
        return max(remaining, 0)
    }
    
    // Calculates a decimal between 0.0 and 1.0 for the SwiftUI ProgressView
    func progressRatio(for goal: SavingsGoals) -> Double {
        // Prevent dividing by zero, which causes app crashes!
        guard goal.targetAmount > 0 else { return 0.0 }
        
        let ratio = goal.currentAmount / goal.targetAmount
        return min(ratio, 1.0) // Caps the visual progress at 100%
    }
    
    // Formats a string to show the percentage (e.g., "45% Complete")
    func progressPercentageText(for goal: SavingsGoals) -> String {
        let percentage = progressRatio(for: goal) * 100
        return String(format: "%.0f%%", percentage)
    }
    
    // Calculates how many days are left until the target date (if one exists)
    func daysRemainingText(for goal: SavingsGoals) -> String? {
        guard let targetDate = goal.targetDate else { return nil }
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        
        if let days = components.day {
            if days < 0 {
                return "Past due"
            } else if days == 0 {
                return "Due today!"
            } else {
                return "\(days) days left"
            }
        }
        return nil
    }
}
