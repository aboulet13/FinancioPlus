//
//  FinancioWidget.swift
//  FinancioWidget
//
//  Created by Ariane on 16/05/2026.
//

//
//  FinancioWidget.swift
//  FinancioWidget
//

import WidgetKit
import SwiftUI
import SwiftData

// 1. THE TIMELINE PROVIDER (The Data Fetcher)
// This dictates WHEN the widget updates and fetches the latest SwiftData.
struct Provider: TimelineProvider {
    
    // Provides a dummy view for when the widget is loading
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalBalance: 1250.00)
    }

    // Provides the preview data seen in the iOS Widget Gallery
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), totalBalance: 1250.00)
        completion(entry)
    }

    // The main engine. This is called periodically by iOS to update the widget.
    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        // Step A: Fetch accounts from our Shared SwiftData Container
        let container = SharedSwiftData.sharedContainer
        let descriptor = FetchDescriptor<Account>()
        
        // Safely try to fetch the accounts. If it fails, default to an empty array.
        let accounts = (try? container.mainContext.fetch(descriptor)) ?? []
        
        // Step B: Calculate the total balance (just like we did in DashboardViewModel)
        let activeAccounts = accounts.filter { $0.isArchived == false }
        let totalBalance = activeAccounts.reduce(0) { $0 + $1.balance }
        
        // Step C: Create an entry with the current time and the calculated balance
        let entry = SimpleEntry(date: Date(), totalBalance: totalBalance)
        
        // Step D: Tell iOS to update this widget again at the end of its natural cycle
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// 2. THE ENTRY (The Data Model for the Widget)
struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalBalance: Double
}

// 3. THE WIDGET VIEW (The UI)
struct FinancioWidgetEntryView : View {
    var entry: Provider.Entry

    // NEW: We tell the Widget to read the currency setting from the shared folder!
    // Make sure this App Group string perfectly matches the one in SettingsView.
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "building.columns.fill")
                    .foregroundStyle(.blue)
                Text("Total Balance")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // NEW: We now use the dynamic variable instead of the hardcoded "USD"
            Text(entry.totalBalance, format: .currency(code: selectedCurrencyCode))
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}
// 4. THE WIDGET CONFIGURATION (The Entry Point)
struct FinancioWidget: Widget {
    let kind: String = "FinancioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FinancioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Total Balance")
        .description("Keep track of your overall financial health at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Supports small square and medium rectangle widgets
    }
}
