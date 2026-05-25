//
//  DashboardView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. FETCH DATA
    // We request the persistent arrays directly from SwiftData container context
    @Query private var accounts: [Account]
    @Query(sort: \BudgetTransaction.date, order: .reverse) private var transactions: [BudgetTransaction]
    
    // 2. INJECT INTO VIEWMODEL
    // We use @State here because DashboardViewModel is now an @Observable class.
    // This allows the view to own the model and react to its calculated properties.
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            // A ScrollView with a subtle background color allows white cards to "pop"
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1. HERO SECTION: Net Worth / Total Balance
                    heroCard
                    
                    // 2. GRAPH SPACE: Scrollable Cards (Line & Donut)
                    scrollableChartsSection
                    
                    // 3. CHART SECTION: Displays asset allocation distribution
                    assetAllocationCard
                    
                    // 4. CASH FLOW SECTION
                    cashFlowCard
                    
                    // 5. ACTION CENTER: Savings & Reports
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
            // Update the ViewModel when the View first loads
            .onAppear {
                viewModel.accounts = accounts
                viewModel.transactions = transactions
            }
            // Keep the ViewModel in sync if SwiftData changes the accounts array
            .onChange(of: accounts) { _, newAccounts in
                viewModel.accounts = newAccounts
            }
            // Keep the ViewModel in sync if SwiftData changes the transactions array
            .onChange(of: transactions) { _, newTransactions in
                viewModel.transactions = newTransactions
            }
        }
    }
    
    // MARK: - UI Components
    
    // The sideways scrollable section for our current month insights
    private var scrollableChartsSection: some View {
        TabView {
            // CARD 1: Line Graph for Daily Spending
            ChartCard(title: "Daily Spending (This Month)") {
                if viewModel.dailySpendingsData.isEmpty {
                    Text("No spending data yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart(viewModel.dailySpendingsData) { item in
                        LineMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Amount", item.amount)
                        )
                        .interpolationMethod(.monotone) // Smooth curved line
                        .foregroundStyle(.blue)
                        
                        AreaMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Amount", item.amount)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue.opacity(0.4), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            if let date = value.as(Date.self) {
                                let day = Calendar.current.component(.day, from: date)
                                // Only show labels for the 1st or every 5th day to keep it clean
                                if day % 5 == 0 || day == 1 {
                                    AxisValueLabel(format: .dateTime.day())
                                }
                            }
                        }
                    }
                }
            }
            
            // CARD 2: Donut Graph for Category Spending
            ChartCard(title: "Spending by Category") {
                if viewModel.spendingByCategoryData.isEmpty {
                    Text("No expenses yet this month.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart(viewModel.spendingByCategoryData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6), // Creates the donut hole
                            angularInset: 1.5 // Visual spacing between slices
                        )
                        .foregroundStyle(by: .value("Category", item.categoryName))
                    }
                }
            }
        }
        // Native iOS pagination
        .tabViewStyle(.page(indexDisplayMode: .always))
        // Fixed height to look like a sturdy widget
        .frame(height: 380)
        // Offset negative padding to counteract TabView's default dot spacing
        .padding(.bottom, -16)
    }

    // A reusable UI component ensuring all swipeable charts look like identical cards
    private struct ChartCard<Content: View>: View {
        let title: String
        let content: Content
        
        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.headline)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            // Pushes the card up slightly so the TabView dots rest outside the white card area
            .padding(.bottom, 40)
            // Ensures the shadow doesn't get clipped by the TabView frame
            .padding(.horizontal, 4)
        }
    }
    
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
    }
}

#Preview {
    DashboardView()
}
