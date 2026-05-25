//
//  DashboardView.swift
//  Financio
//
<<<<<<< HEAD
=======
//  Created by Ariane Boulet on 12/04/2026.
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    
<<<<<<< HEAD
    @Environment(\.modelContext) private var modelContext
    
    // 1. FETCH DATA
    // We request the persistent arrays directly from SwiftData container context
    @Query private var accounts: [Account]
    @Query(sort: \BudgetTransaction.date, order: .reverse) private var transactions: [BudgetTransaction]
    
    // 2. INJECT INTO VIEWMODEL
    // We treat this struct as a pure data transformer to parse mathematical queries cleanly
    private var viewModel: DashboardViewModel {
        DashboardViewModel(accounts: accounts, transactions: transactions)
    }
    
    var body: some View {
        NavigationStack {
            // A ScrollView with a subtle background color allows white cards to "pop"
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1. HERO SECTION: Net Worth / Total Balance
                    heroCard
                    
                    // 2. CHART SECTION: Displays asset allocation distribution
                    assetAllocationCard
                    
                    // 3. CASH FLOW SECTION
                    cashFlowCard
                    
                    // 4. ACTION CENTER: Savings & Reports
                    actionCenterCard
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground)) // The classic iOS light gray background
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    QuickAddMenu() // Instant global shortcut insertion panel
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    // Upgraded Asset Allocation Card utilizing optimized SectorMark signatures
    private var assetAllocationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Asset Allocation")
                .font(.headline)
            
            // Defend against empty database sets to avoid rendering math crash artifacts
            if !viewModel.hasLiquidityData {
                ContentUnavailableView(
                    "No Funds Registered",
                    systemImage: "chart.pie",
                    description: Text("Your liquid breakdown appears once balances are entered into active accounts.")
                )
            } else {
                HStack(spacing: 24) {
                    // Loop over the identifiable chart struct items from our ViewModel
                    Chart(viewModel.liquidityChartData) { item in
                        // SectorMark draws the radial sectors of the distribution pie
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.65) // Trims the inner mass out to form a perfect donut ring
                        )
                        .foregroundStyle(item.color.gradient)
                    }
                    .frame(width: 120, height: 120)
                    
                    // The Itemized Visual Legend Panel
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.liquidityChartData) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(item.bucketName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                MoneyText(amount: item.amount)
                                    .font(.caption)
                                    .bold()
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // The big, prominent Net Worth card tracking liquidity metrics
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top: Total Net Worth Value Display
            VStack(alignment: .leading, spacing: 4) {
                Text("Net Worth")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                MoneyText(amount: viewModel.netWorth)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.netWorth >= 0 ? Color.primary : Color.red)
            }
            
            // Separator dividing the aggregate metric from the column list
            Divider()
                        
            // Bottom: Three column structural layout mapping out current availability
            HStack(alignment: .top) {
                // Column 1: Usable Checking/Cash funds
                VStack(alignment: .leading, spacing: 4) {
                    Text("Usable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: viewModel.usableAmount)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                // Column 2: Safety Savings allocations
                VStack(alignment: .center, spacing: 4) {
                    Text("Savings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: viewModel.savingsAmount)
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                // Column 3: Long term invested growth values
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Invested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: viewModel.investmentAmount)
                        .font(.headline)
                        .foregroundStyle(.purple)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // The Cash Flow monthly performance visualizer
    private var cashFlowCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month's Cash Flow")
                .font(.headline)
            
            HStack {
                // Income Indicator Column
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle().fill(.green).frame(width: 8, height: 8)
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    MoneyText(amount: viewModel.incomeThisMonth)
                        .font(.title3)
                        .bold()
                }
                
                Spacer()
                
                // Expense Indicator Column
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Circle().fill(.red).frame(width: 8, height: 8)
                    }
                    MoneyText(amount: viewModel.expensesThisMonth)
                        .font(.title3)
                        .bold()
                }
            }
            
            Divider()
            
            // Final Delta Summary Section
            HStack {
                Text("Net Income")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                MoneyText(amount: viewModel.netCashFlowThisMonth)
                    .font(.headline)
                    .foregroundStyle(viewModel.netCashFlowThisMonth >= 0 ? .green : .red)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // Modular navigation links container block row mapping
    private var actionCenterCard: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: SavingsGoalsListView()) {
                HStack {
                    Image(systemName: "target")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 30)
                    
                    Text("Savings Goals")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding(20)
            }
            
            Divider().padding(.leading, 60)
            
            NavigationLink(destination: ReportsView()) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .frame(width: 30)
                    
                    Text("Monthly Reports")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding(20)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
=======
    @Query private var accounts: [Account]
    
    @Query(sort: \BudgetTransaction.date, order: .reverse)
    private var transactions: [BudgetTransaction]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Summary cards section
                    VStack(spacing: 12) {
                        SummaryCardView(
                            title: "Total Balance",
                            amount: totalBalance,
                            color: .blue
                        )
                        
                        SummaryCardView(
                            title: "Income This Month",
                            amount: incomeThisMonth,
                            color: .green
                        )
                        
                        SummaryCardView(
                            title: "Expenses This Month",
                            amount: expensesThisMonth,
                            color: .red
                        )
                        
                        SummaryCardView(
                            title: "Net Cash Flow",
                            amount: netCashFlowThisMonth,
                            color: netCashFlowColor
                        )
                    }
                    .padding(.horizontal)
                    
                    // Navigation to Reports
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insights")
                            .font(.title2)
                            .bold()
                        
                        NavigationLink {
                            ReportsView()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("View Full Reports")
                                        .font(.headline)
                                    
                                    Text("See monthly income, expenses, and cash flow trends.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    
                    // Spending by category chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending by Category")
                            .font(.title2)
                            .bold()
                        
                        if spendingByCategoryData.isEmpty {
                            ContentUnavailableView(
                                "No Expense Data Yet",
                                systemImage: "chart.bar.xaxis",
                                description: Text("Your monthly spending chart will appear here once you add expense transactions.")
                            )
                        } else {
                            Chart(spendingByCategoryData, id: \.categoryName) { item in
                                BarMark(
                                    x: .value("Category", item.categoryName),
                                    y: .value("Amount", item.amount)
                                )
                                .foregroundStyle(.red.gradient)
                            }
                            .frame(height: 220)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Top spending category section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Spending Category")
                            .font(.title2)
                            .bold()
                        
                        if let topCategory = topSpendingCategory {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(topCategory.name)
                                    .font(.headline)
                                
                                MoneyText(amount: topCategory.amount)
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ContentUnavailableView(
                                "No Spending Data Yet",
                                systemImage: "chart.bar",
                                description: Text("Your top spending category will appear here once you add expense transactions.")
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent transactions section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Transactions")
                            .font(.title2)
                            .bold()
                        
                        if recentTransactions.isEmpty {
                            ContentUnavailableView(
                                "No Recent Transactions",
                                systemImage: "tray",
                                description: Text("Your recent activity will appear here.")
                            )
                        } else {
                            ForEach(recentTransactions) { transaction in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(transaction.title)
                                            .font(.headline)
                                        
                                        Text(transaction.type.rawValue)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    MoneyText(amount: transaction.amount)
                                        .bold()
                                        .foregroundStyle(amountColor(for: transaction.type))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
    
    // Returns only accounts that are not archived.
    private var activeAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == false
        }
    }
    
    // Computes the total balance across active accounts only.
    private var totalBalance: Double {
        activeAccounts.reduce(0) { partialResult, account in
            partialResult + account.balance
        }
    }
    
    // Computes total income for the current month.
    private var incomeThisMonth: Double {
        transactions
            .filter { transaction in
                transaction.type == .income && isInCurrentMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    // Computes total expenses for the current month.
    private var expensesThisMonth: Double {
        transactions
            .filter { transaction in
                transaction.type == .expense && isInCurrentMonth(transaction.date)
            }
            .reduce(0) { partialResult, transaction in
                partialResult + transaction.amount
            }
    }
    
    // Computes net cash flow for the current month.
    private var netCashFlowThisMonth: Double {
        incomeThisMonth - expensesThisMonth
    }
    
    // Chooses a color for the net cash flow card.
    private var netCashFlowColor: Color {
        if netCashFlowThisMonth > 0 {
            return .green
        } else if netCashFlowThisMonth < 0 {
            return .red
        } else {
            return .blue
        }
    }
    
    // Returns only the 5 most recent transactions.
    private var recentTransactions: [BudgetTransaction] {
        Array(transactions.prefix(5))
    }
    
    // Builds chart data showing expense totals by category for the current month.
    private var spendingByCategoryData: [(categoryName: String, amount: Double)] {
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
    private var topSpendingCategory: (name: String, amount: Double)? {
        guard let topEntry = spendingByCategoryData.first else {
            return nil
        }
        
        return (name: topEntry.categoryName, amount: topEntry.amount)
    }
    
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
    private func amountColor(for type: TransactionType) -> Color {
        switch type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    }
}

#Preview {
    DashboardView()
}
