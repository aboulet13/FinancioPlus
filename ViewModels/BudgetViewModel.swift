//
//  BudgetViewModel.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftUI

// The ViewModel acts as our data processor. It takes raw arrays and
// current UI state, and transforms them into formatted data for the View.
struct BudgetViewModel {
    
    // 1. RAW INGREDIENTS
    // Passed in from the View's SwiftData @Query and @State properties.
    let budgets: [Budget]
    let transactions: [BudgetTransaction]
    let selectedMonth: Int
    let selectedYear: Int
    
    // 2. COMPUTED DATA
    // Filters the overall budgets array to show only those for the chosen month/year.
    var selectedMonthBudgets: [Budget] {
        budgets.filter { budget in
            budget.month == selectedMonth && budget.year == selectedYear
        }
    }
    
    // Formats the month and year into a nice readable title (e.g., "April 2026").
    var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy" // LLLL is the standalone full month name
        
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        
        return formatter.string(from: date)
    }
    
    // 3. BUDGET MATH LOGIC
    // Calculates how much has been spent against a specific budget.
    func spentAmount(for budget: Budget) -> Double {
        guard let category = budget.category else { return 0 }
        
        return transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.category?.id == category.id &&
                isInSelectedMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    // Calculates the remaining amount for a specific budget.
    func remainingAmount(for budget: Budget) -> Double {
        budget.plannedAmount - spentAmount(for: budget)
    }
    
    // Calculates the decimal ratio (0.0 to 1.0) for the SwiftUI ProgressView.
    func progressValue(for budget: Budget) -> Double {
        guard budget.plannedAmount > 0 else { return 0 }
        
        let ratio = spentAmount(for: budget) / budget.plannedAmount
        return min(ratio, 1.0) // Caps the progress bar at 100% full
    }
    
    // Generates the readable text showing percentage used.
    func progressText(for budget: Budget) -> String {
        guard budget.plannedAmount > 0 else { return "No budget set" }
        
        let percentage = (spentAmount(for: budget) / budget.plannedAmount) * 100
        
        // Slightly updated to warn the user if they went over 100%
        if percentage > 100 {
            return String(format: "Over budget by %.0f%%", percentage - 100)
        } else {
            return String(format: "%.0f%% of budget used", percentage)
        }
    }
    
    // UPDATED: Determines if the progress bar should be red (over budget) or the Category's color!
    func progressColor(for budget: Budget) -> Color {
        if remainingAmount(for: budget) < 0 {
            return .red
        } else if let hex = budget.category?.colorHex {
            return Color(hex: hex)
        } else {
            return .blue // Fallback
        }
    }
    
    // Helper function to verify if a transaction falls within the viewed month.
    private func isInSelectedMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return month == selectedMonth && year == selectedYear
    }
}
