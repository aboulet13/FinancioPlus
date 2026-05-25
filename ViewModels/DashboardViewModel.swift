//
//  DashboardViewModel.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import Foundation
import SwiftUI

// We use a struct for the ViewModel here because it acts as a "Data Transformer".
// It takes the raw data from SwiftData and calculates all our business logic metrics.
struct DashboardViewModel {
    
    // 1. THE RAW INGREDIENTS
    // The View will pass these arrays in whenever the SwiftData @Query updates.
    let accounts: [Account]
    let transactions: [BudgetTransaction]
    
    // 2. THE CALCULATED METRICS
    // We moved all the logic from the View into these computed properties.
    
    // Returns only accounts that are not archived.
    var activeAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == false
        }
    }
    
    // MARK: - Financio+ Net Worth Engine
    var totalAssets: Double {
        let activeAccounts = accounts.filter { !$0.isArchived }
        // Only sum accounts categorized as Assets
        return activeAccounts
            .filter { $0.category == .asset }
            .reduce(0) { $0 + $1.balance }
    }
    
    var totalLiabilities: Double {
        let activeAccounts = accounts.filter { !$0.isArchived }
        
        let rawSum = activeAccounts
            .filter { $0.category == .liability }
            .reduce(0) { $0 + $1.balance }
            
        // We wrap the final sum in abs() so the Net Worth subtraction
        // works perfectly, whether the user typed $1500 or -$1500!
        return abs(rawSum)
    }
    
    var netWorth: Double {
        // The ultimate financial metric
        return totalAssets - totalLiabilities
    }
    
    // Computes total income for the current month.
    var incomeThisMonth: Double {
        transactions
            .filter { transaction in
                transaction.type == .income && isInCurrentMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    // Computes total expenses for the current month.
    var expensesThisMonth: Double {
        transactions
            .filter { transaction in
                transaction.type == .expense && isInCurrentMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    // Computes net cash flow for the current month.
    var netCashFlowThisMonth: Double {
        incomeThisMonth - expensesThisMonth
    }
    
    // Chooses a color for the net cash flow card.
    var netCashFlowColor: Color {
        if netCashFlowThisMonth > 0 {
            return .green
        } else if netCashFlowThisMonth < 0 {
            return .red
        } else {
            return .blue
        }
    }
    
    // Returns only the 5 most recent transactions.
    var recentTransactions: [BudgetTransaction] {
        Array(transactions.prefix(5))
    }
    
    // Builds chart data showing expense totals by category for the current month.
    var spendingByCategoryData: [(categoryName: String, amount: Double)] {
        let expenseTransactions = transactions.filter { transaction in
            transaction.type == .expense &&
            isInCurrentMonth(transaction.date) &&
            transaction.category != nil
        }
        
        var totalsByCategory: [String: Double] = [:]
        
        for transaction in expenseTransactions {
            let categoryName = transaction.category?.name ?? "Unknown"
            totalsByCategory[categoryName, default: 0] += transaction.amount
        }
        
        return totalsByCategory
            .map { entry in
                (categoryName: entry.key, amount: entry.value)
            }
            .sorted { first, second in
                first.amount > second.amount
            }
    }
    
    // Computes the category with the highest spending in the current month.
    var topSpendingCategory: (name: String, amount: Double)? {
        guard let topEntry = spendingByCategoryData.first else {
            return nil
        }
        
        return (name: topEntry.categoryName, amount: topEntry.amount)
    }
    
    // MARK: - Liquidity Metrics
        
    var usableAmount: Double {
        let activeAccounts = accounts.filter { !$0.isArchived }
        
        // Usable money is liquid cash (Checking & Cash accounts)
        // If you want to deduct credit card debt from this, you could subtract it here!
        return activeAccounts
            .filter { $0.type == .checking || $0.type == .cash }
            .reduce(0) { $0 + $1.balance }
    }
    
    var savingsAmount: Double {
        let activeAccounts = accounts.filter { !$0.isArchived }
        
        // Money set aside for short/medium-term goals
        return activeAccounts
            .filter { $0.type == .savings }
            .reduce(0) { $0 + $1.balance }
    }
    
    var investmentAmount: Double {
        let activeAccounts = accounts.filter { !$0.isArchived }
        
        // Long-term wealth building
        return activeAccounts
            .filter { $0.type == .investment } // Maps to your database schema requirements
            .reduce(0) { $0 + $1.balance }
    }
    
    // MARK: - Swift Charts Data Transformers
    
    // A simple, lightweight data structure used to feed our Liquidity Chart.
    // By conforming to Identifiable, SwiftUI Charts can loop over it safely.
    struct LiquidityChartItem: Identifiable {
        let id = UUID()
        let bucketName: String
        let amount: Double
        let color: Color
    }
    
    // Computed property that wraps our raw liquidity math into clean chart items.
    // First-year CS concept: This transforms an internal data representation
    // into an external format tailored for consumption by the user interface.
    var liquidityChartData: [LiquidityChartItem] {
        return [
            LiquidityChartItem(bucketName: "Usable", amount: usableAmount, color: .blue),
            LiquidityChartItem(bucketName: "Savings", amount: savingsAmount, color: .green),
            LiquidityChartItem(bucketName: "Invested", amount: investmentAmount, color: .purple)
        ]
    }
    
    // Checks if the user has any money tracked at all.
    // This helps us avoid showing an empty chart to a brand new user.
    var hasLiquidityData: Bool {
        usableAmount > 0 || savingsAmount > 0 || investmentAmount > 0
    }
    
    // 3. HELPER FUNCTIONS
    
    // Checks whether a date belongs to the current month and year.
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let transactionMonth = calendar.component(.month, from: date)
        let transactionYear = calendar.component(.year, from: date)
        
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        return transactionMonth == currentMonth && transactionYear == currentYear
    }
    
    // Returns a color depending on transaction type.
    func amountColor(for type: TransactionType) -> Color {
        switch type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
}
