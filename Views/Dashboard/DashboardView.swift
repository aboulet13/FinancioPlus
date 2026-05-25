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
    }
}

#Preview {
    DashboardView()
}
