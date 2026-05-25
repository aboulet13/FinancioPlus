//
//  ReportsView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    
    // Fetch all transactions sorted by date.
    @Query(sort: \BudgetTransaction.date)
    private var transactions: [BudgetTransaction]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Section title
                    Text("Monthly Income vs Expenses")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    if monthlyReportData.isEmpty {
                        ContentUnavailableView(
                            "No Report Data Yet",
                            systemImage: "chart.bar.doc.horizontal",
                            description: Text("Add transactions over time to see monthly reports.")
                        )
                    } else {
                        Chart {
                            ForEach(monthlyReportData, id: \.monthLabel) { item in
                                
                                // Income bar
                                BarMark(
                                    x: .value("Month", item.monthLabel),
                                    y: .value("Income", item.income)
                                )
                                .foregroundStyle(.green)
                                .position(by: .value("Type", "Income"))
                                
                                // Expense bar
                                BarMark(
                                    x: .value("Month", item.monthLabel),
                                    y: .value("Expenses", item.expenses)
                                )
                                .foregroundStyle(.red)
                                .position(by: .value("Type", "Expenses"))
                            }
                        }
                        .frame(height: 260)
                        .padding(.horizontal)
                    }
                    
                    // Net cash flow summary section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Net Cash Flow by Month")
                            .font(.title2)
                            .bold()
                        
                        if monthlyReportData.isEmpty {
                            ContentUnavailableView(
                                "No Cash Flow Data Yet",
                                systemImage: "chart.line.uptrend.xyaxis",
                                description: Text("Monthly cash flow will appear here once you add transactions.")
                            )
                        } else {
                            ForEach(monthlyReportData, id: \.monthLabel) { item in
                                HStack {
                                    Text(item.monthLabel)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    MoneyText(amount: item.netCashFlow)
                                        .bold()
                                        .foregroundStyle(item.netCashFlow >= 0 ? .green : .red)
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
            .navigationTitle("Reports")
        }
    }
    
    // Aggregates transactions into monthly report entries.
    private var monthlyReportData: [MonthlyReportItem] {
        let calendar = Calendar.current
        
        // Dictionary keyed by "year-month" to accumulate values.
        var groupedData: [String: MonthlyReportItem] = [:]
        
        for transaction in transactions {
            let year = calendar.component(.year, from: transaction.date)
            let month = calendar.component(.month, from: transaction.date)
            
            let key = "\(year)-\(month)"
            let monthLabel = formattedMonthLabel(year: year, month: month)
            
            // If no entry exists for this month yet, create one.
            if groupedData[key] == nil {
                groupedData[key] = MonthlyReportItem(
                    monthKey: key,
                    monthLabel: monthLabel,
                    income: 0,
                    expenses: 0
                )
            }
            
            // Update the correct monthly totals depending on transaction type.
            switch transaction.type {
            case .income:
                groupedData[key]?.income += transaction.amount
            case .expense:
                groupedData[key]?.expenses += transaction.amount
            case .transfer:
                // Transfers do not count as income or expenses in reports.
                break
            }
        }
        
        // Return sorted by month key so the chart appears in chronological order.
        return groupedData.values.sorted { first, second in
            first.monthKey < second.monthKey
        }
    }
    
    // Builds a short readable month label like "Apr 2026".
    private func formattedMonthLabel(year: Int, month: Int) -> String {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        return formatter.string(from: date)
    }
}

// A simple struct representing one month of report data.
struct MonthlyReportItem {
    let monthKey: String
    let monthLabel: String
    var income: Double
    var expenses: Double
    
    // Computed property for monthly net cash flow.
    var netCashFlow: Double {
        income - expenses
    }
}

#Preview {
    ReportsView()
}
