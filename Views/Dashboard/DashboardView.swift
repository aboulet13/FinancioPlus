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
    
    // We bring in the currency preference for formatting
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "EUR"
    
    @AppStorage("weeklyDiscretionaryLimit") private var weeklyLimit: Double = 50.0
    
    // 1. FETCH DATA
    @Query private var accounts: [Account]
    @Query(sort: \BudgetTransaction.date, order: .reverse) private var transactions: [BudgetTransaction]
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var budgets: [Budget]
    
    // 2. INJECT INTO VIEWMODEL
    @State private var viewModel = DashboardViewModel()
    
    // 3. UI PREFERENCES
    @AppStorage("pinnedBudgetCards") private var pinnedBudgetCardsString: String = ""
    
    @State private var isEditingBudgets: Bool = false
    @State private var isEditingWeeklyLimit: Bool = false
    @State private var newWeeklyLimitString: String = ""
    
    private var pinnedCategoryIDs: [UUID] {
        pinnedBudgetCardsString.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1. WEEKLY PULSE HERO CARD
                    weeklyPulseCard
                    
                    // 2. HERO SECTION: Cash Flow (Updated!)
                    cashFlowCard
                    
                    // 3. BUDGET GRID SECTION
                    budgetsSection
                    
                    // 4. GRAPH SPACE: Scrollable Cards (Line & Donut)
                    scrollableChartsSection
                    
                    // 5. CHART SECTION: Displays asset allocation distribution
                    assetAllocationCard
                    
                    // 6. ACTION CENTER: Savings & Reports
                    actionCenterCard
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    QuickAddMenu()
                }
            }
            .onAppear {
                viewModel.accounts = accounts
                viewModel.transactions = transactions
            }
            .onChange(of: accounts) { _, newAccounts in
                viewModel.accounts = newAccounts
            }
            .onChange(of: transactions) { _, newTransactions in
                viewModel.transactions = newTransactions
            }
            .onTapGesture {
                if isEditingBudgets {
                    withAnimation { isEditingBudgets = false }
                }
            }
            .alert("Set Weekly Limit", isPresented: $isEditingWeeklyLimit) {
                TextField("Amount", text: $newWeeklyLimitString)
                    .keyboardType(.decimalPad)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let newLimit = Double(newWeeklyLimitString.replacingOccurrences(of: ",", with: ".")) {
                        weeklyLimit = newLimit
                    }
                }
            } message: {
                Text("Enter the maximum amount you want to spend this week.")
            }
        }
    }
    
    // MARK: - Dashboard Math & Data
    
    private var spentThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }
        
        return transactions.filter { txn in
            txn.type == .expense && weekInterval.contains(txn.date)
        }.reduce(0) { $0 + $1.amount }
    }
    
    // NEW: Calculate transfers to Savings this month
    private var savedThisMonth: Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return transactions.filter { txn in
            let isThisMonth = calendar.component(.month, from: txn.date) == currentMonth &&
                              calendar.component(.year, from: txn.date) == currentYear
            let isTransferToSavings = txn.type == .transfer && txn.toAccount?.type == .savings
            // Exclude internal transfers from another savings account
            let notFromSavings = txn.account?.type != .savings
            
            return isThisMonth && isTransferToSavings && notFromSavings
        }.reduce(0) { $0 + $1.amount }
    }
    
    // NEW: Calculate transfers to Investments this month
    private var investedThisMonth: Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return transactions.filter { txn in
            let isThisMonth = calendar.component(.month, from: txn.date) == currentMonth &&
                              calendar.component(.year, from: txn.date) == currentYear
            let isTransferToInvestment = txn.type == .transfer && txn.toAccount?.type == .investment
            // Exclude internal transfers from another investment account
            let notFromInvestment = txn.account?.type != .investment
            
            return isThisMonth && isTransferToInvestment && notFromInvestment
        }.reduce(0) { $0 + $1.amount }
    }
    
    // NEW: Usable Net Income (Income - Expenses - Saved - Invested)
    private var usableNetIncomeThisMonth: Double {
        return viewModel.incomeThisMonth - viewModel.expensesThisMonth - savedThisMonth - investedThisMonth
    }
    
    // MARK: - UI Components
    
    private var weeklyPulseCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Pulse")
                        .font(.headline)
                    Text("Resets every Monday")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    newWeeklyLimitString = String(format: "%.0f", weeklyLimit)
                    isEditingWeeklyLimit = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            let progress = min(spentThisWeek / weeklyLimit, 1.0)
            let remaining = max(weeklyLimit - spentThisWeek, 0)
            let isOverBudget = spentThisWeek > weeklyLimit
            
            HStack(alignment: .bottom) {
                MoneyText(amount: spentThisWeek)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(isOverBudget ? .red : .primary)
                
                Text("/ \(weeklyLimit.formatted(.currency(code: selectedCurrencyCode)))")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 5)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: remaining)
                        .font(.headline)
                        .foregroundStyle(remaining > 0 ? .green : .red)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(isOverBudget ? Color.red : Color.blue)
                        .frame(width: max(0, geo.size.width * CGFloat(progress)))
                }
            }
            .frame(height: 10)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // UPDATED: 3-Tier Cash Flow Card
    private var cashFlowCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month's Cash Flow")
                .font(.headline)
            
            // Tier 1: Income vs Expenses
            HStack {
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
            
            // Tier 2: Saved vs Invested
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: savedThisMonth)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Invested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: investedThisMonth)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.purple)
                }
            }
            
            Divider()
            
            // Tier 3: Usable Net Income
            HStack {
                Text("Usable Net Income")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                MoneyText(amount: usableNetIncomeThisMonth)
                    .font(.headline)
                    .foregroundStyle(usableNetIncomeThisMonth >= 0 ? .green : .red)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Month’s Budget")
                    .font(.headline)
                
                Button {
                    addNewBudgetCard()
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
                
                Spacer()
                
                if isEditingBudgets {
                    Button("Done") {
                        withAnimation { isEditingBudgets = false }
                    }
                    .font(.subheadline.bold())
                }
            }
            .padding(.top, 8)
            
            if pinnedCategoryIDs.isEmpty {
                Text("Tap the + to pin a budget category here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(pinnedCategoryIDs.enumerated()), id: \.offset) { index, categoryID in
                        DashboardBudgetCard(
                            categoryID: categoryID,
                            categories: categories,
                            budgets: budgets,
                            transactions: transactions,
                            isEditing: isEditingBudgets,
                            onRemove: { removeBudgetCard(at: index) },
                            onChangeCategory: { newCategory in updateBudgetCard(at: index, with: newCategory.id) }
                        )
                        .onLongPressGesture {
                            withAnimation { isEditingBudgets = true }
                        }
                    }
                }
            }
        }
    }
    
    private var scrollableChartsSection: some View {
        TabView {
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
                        .interpolationMethod(.monotone)
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
                                if day % 5 == 0 || day == 1 {
                                    AxisValueLabel(format: .dateTime.day())
                                }
                            }
                        }
                    }
                }
            }
            
            ChartCard(title: "Spending by Category") {
                if viewModel.spendingByCategoryData.isEmpty {
                    Text("No expenses yet this month.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart(viewModel.spendingByCategoryData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", item.categoryName))
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 380)
        .padding(.bottom, -16)
    }

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
            .padding(.bottom, 40)
            .padding(.horizontal, 4)
        }
    }
    
    private var assetAllocationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Asset Allocation")
                .font(.headline)
            
            if !viewModel.hasLiquidityData {
                ContentUnavailableView(
                    "No Funds Registered",
                    systemImage: "chart.pie",
                    description: Text("Your liquid breakdown appears once balances are entered into active accounts.")
                )
            } else {
                HStack(spacing: 24) {
                    Chart(viewModel.liquidityChartData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.65)
                        )
                        .foregroundStyle(item.color.gradient)
                    }
                    .frame(width: 120, height: 120)
                    
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
    
    // MARK: - AppStorage Array Logic
    
    private func addNewBudgetCard() {
        var currentIDs = pinnedCategoryIDs
        let newID = categories.first?.id ?? UUID()
        currentIDs.append(newID)
        pinnedBudgetCardsString = currentIDs.map { $0.uuidString }.joined(separator: ",")
    }

    private func removeBudgetCard(at index: Int) {
        var currentIDs = pinnedCategoryIDs
        currentIDs.remove(at: index)
        pinnedBudgetCardsString = currentIDs.map { $0.uuidString }.joined(separator: ",")
    }

    private func updateBudgetCard(at index: Int, with newID: UUID) {
        var currentIDs = pinnedCategoryIDs
        currentIDs[index] = newID
        pinnedBudgetCardsString = currentIDs.map { $0.uuidString }.joined(separator: ",")
    }
}

// MARK: - Reusable Budget Card Component
struct DashboardBudgetCard: View {
    let categoryID: UUID
    let categories: [Category]
    let budgets: [Budget]
    let transactions: [BudgetTransaction]
    
    let isEditing: Bool
    let onRemove: () -> Void
    let onChangeCategory: (Category) -> Void
    
    @State private var wigglePhase: CGFloat = 0

    private var currentCategory: Category? {
        categories.first(where: { $0.id == categoryID })
    }
    
    private var plannedAmount: Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        return budgets.first(where: { $0.category?.id == categoryID && $0.month == currentMonth && $0.year == currentYear })?.plannedAmount ?? 0.0
    }
    
    private var spentAmount: Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return transactions
            .filter { txn in
                guard let cat = txn.category, cat.id == categoryID else { return false }
                let month = Calendar.current.component(.month, from: txn.date)
                let year = Calendar.current.component(.year, from: txn.date)
                return month == currentMonth && year == currentYear
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var remainingAmount: Double {
        max(plannedAmount - spentAmount, 0)
    }
    
    private var progress: Double {
        guard plannedAmount > 0 else { return 0 }
        return min(spentAmount / plannedAmount, 1.0)
    }
    
    private var percentageText: String {
        guard plannedAmount > 0 else { return "No budget set" }
        let percent = Int((spentAmount / plannedAmount) * 100)
        return "\(percent)% of budget used"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                Menu {
                    ForEach(categories) { category in
                        Button(category.name) {
                            onChangeCategory(category)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currentCategory?.name ?? "Select")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        MoneyText(amount: spentAmount)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        MoneyText(amount: remainingAmount)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                            
                            Capsule()
                                .fill(progress >= 1.0 ? Color.red : Color.blue)
                                .frame(width: geo.size.width * CGFloat(progress))
                        }
                    }
                    .frame(height: 6)
                    
                    Text(percentageText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            if isEditing {
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white, .red)
                        .background(Circle().fill(Color.white))
                }
                .offset(x: -8, y: -8)
            }
        }
        .rotationEffect(.degrees(isEditing ? wigglePhase : 0))
        .onChange(of: isEditing) { _, editing in
            if editing {
                withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
                    wigglePhase = 1.5
                }
            } else {
                withAnimation { wigglePhase = 0 }
            }
        }
        .onAppear {
            if isEditing { wigglePhase = -1.5 }
        }
    }
}
