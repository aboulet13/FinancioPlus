//
//  DashboardViewModelTests.swift
//  FinancioTests
//
//  Created by Ariane Boulet on 10/04/2026.
//

import Testing
import Foundation
@testable import Financio // This gives our test file permission to read our main app's code

// We create a "Suite" to group all tests related to the Dashboard
struct DashboardViewModelTests {

    @Test("Calculates total balance correctly, ignoring archived accounts")
    func totalBalanceCalculation() async throws {
        // 1. GIVEN: Set up our controlled fake data
        let activeAccount1 = Account(name: "Checking", type: .checking, balance: 1000.0, isArchived: false)
        let activeAccount2 = Account(name: "Savings", type: .savings, balance: 500.0, isArchived: false)
        let archivedAccount = Account(name: "Old Wallet", type: .cash, balance: 9999.0, isArchived: true)
        
        let fakeAccounts = [activeAccount1, activeAccount2, archivedAccount]
        
        // 2. WHEN: We initialize the ViewModel with our fake data
        let viewModel = DashboardViewModel(
            accounts: fakeAccounts,
            transactions: [] // We don't need transactions for this specific test
        )
        
        // 3. THEN: We expect the balance to be exactly $1500 (ignoring the $9999 archived one)
        // #expect is the magic macro that will turn green if true, or red if our math is broken.
        #expect(viewModel.totalBalance == 1500.0)
    }
    
    @Test("Calculates net cash flow correctly for the current month")
    func netCashFlowCalculation() async throws {
        // 1. GIVEN: Set up fake transactions
        let today = Date()
        
        // Last month's date calculation
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: today) ?? Date()
        
        let incomeToday = BudgetTransaction(title: "Salary", amount: 3000.0, date: today, type: .income, category: nil)
        let expenseToday = BudgetTransaction(title: "Groceries", amount: 500.0, date: today, type: .expense, category: nil)
        let oldExpense = BudgetTransaction(title: "Old Rent", amount: 1000.0, date: lastMonth, type: .expense, category: nil)
        
        let fakeTransactions = [incomeToday, expenseToday, oldExpense]
        
        // 2. WHEN: We initialize the ViewModel
        let viewModel = DashboardViewModel(
            accounts: [], // We don't need accounts for this specific test
            transactions: fakeTransactions
        )
        
        // 3. THEN:
        // Income ($3000) - Expense this month ($500) = $2500
        // It should completely ignore the $1000 expense from last month!
        #expect(viewModel.netCashFlowThisMonth == 2500.0)
        #expect(viewModel.incomeThisMonth == 3000.0)
        #expect(viewModel.expensesThisMonth == 500.0)
    }
}
