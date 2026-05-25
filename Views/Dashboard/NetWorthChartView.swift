//
//  NetWorthChartView.swift
//  Financio
//
//  Created by Ariane on 20/05/2026.
//

import SwiftUI
import SwiftData
import Charts

struct NetWorthChartView: View {
    // NEW: We query the actual historical database, sorted from oldest to newest
    @Query(sort: \NetWorthSnapshot.date, order: .forward) private var snapshots: [NetWorthSnapshot]
    
    // We still pass this in to ensure the chart always finishes exactly on today's real-time balance
    var currentNetWorth: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Net Worth Over Time")
                .font(.headline)
            
            if snapshots.isEmpty {
                // Empty state if they literally just installed the app
                Text("Not enough historical data yet. Check back tomorrow!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(height: 220)
            } else {
                Chart {
                    // 1. Draw the historical data from the database
                    ForEach(snapshots) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Net Worth", point.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Net Worth", point.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    
                    // 2. Append today's LIVE data to the very end of the chart
                    // This ensures the chart reacts instantly when they add an account,
                    // even before the background snapshot engine fires!
                    LineMark(
                        x: .value("Date", Date()),
                        y: .value("Net Worth", currentNetWorth)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis(.hidden)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
