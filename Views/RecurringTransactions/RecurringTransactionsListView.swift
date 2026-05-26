//
//  RecurringTransactionsListView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct RecurringTransactionsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \RecurringTransaction.nextDate)
    private var recurringTransactions: [RecurringTransaction]
    
    @State private var isShowingAddRecurringTransaction = false
    
    // NEW: Stores the recurring rule currently selected for editing.
    @State private var selectedRecurringTransaction: RecurringTransaction?
    
    // Stores the recurring rule the user is about to delete.
    @State private var recurringPendingDeletion: RecurringTransaction?
    
    var body: some View {
        NavigationStack {
            Group {
                if recurringTransactions.isEmpty {
                    ContentUnavailableView(
                        "No Recurring Transactions Yet",
                        systemImage: "arrow.triangle.2.circlepath",
                        description: Text("Add recurring rules for things like rent, salary, or subscriptions.")
                    )
                } else {
                    List {
                        ForEach(recurringTransactions) { recurring in
                            VStack(alignment: .leading, spacing: 8) {
                                
                                // Title
                                Text(recurring.title)
                                    .font(.headline)
                                
                                // Frequency and active/paused state
                                HStack {
                                    Text(recurring.frequency.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(recurring.isActive ? "Active" : "Paused")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(recurring.isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                
                                // Due/upcoming state
                                Text(RecurringTransactionService.isDue(recurring) ? "Due" : "Upcoming")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(RecurringTransactionService.isDue(recurring) ? .red : .secondary)
                                
                                // Next date
                                Text("Next: \(recurring.nextDate, format: .dateTime.day().month().year())")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                // Amount
                                MoneyText(amount: recurring.amount)
                                    .bold()
                                
                                // Apply button
                                if recurring.isActive {
                                    Button {
                                        applyRecurringTransaction(recurring)
                                    } label: {
                                        Label("Apply Now", systemImage: "plus.circle")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.accentColor)
                                }
                            }
                            .padding(.vertical, 6)
                            // NEW: Make the entire row tappable (even the empty spaces)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecurringTransaction = recurring
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    recurringPendingDeletion = recurring
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recurring")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddRecurringTransaction = true
                    } label: {
                        Label("Add Recurring Transaction", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddRecurringTransaction) {
                AddRecurringTransactionView()
            }
            // NEW: The sheet that pops up when a user taps a transaction row
            .sheet(item: $selectedRecurringTransaction) { recurring in
                EditRecurringTransactionView(recurringTransaction: recurring)
            }
            .confirmationDialog(
                "Delete this recurring rule?",
                isPresented: Binding(
                    get: { recurringPendingDeletion != nil },
                    set: { newValue in
                        if newValue == false {
                            recurringPendingDeletion = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Recurring Rule", role: .destructive) {
                    if let recurringPendingDeletion {
                        deleteRecurringTransaction(recurringPendingDeletion)
                        self.recurringPendingDeletion = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    recurringPendingDeletion = nil
                }
            } message: {
                Text("This will stop future automatic applications of this rule. Previously generated transactions will remain unchanged.")
            }
        }
    }
    
    // Applies the recurring transaction rule through the service.
    private func applyRecurringTransaction(_ recurring: RecurringTransaction) {
        RecurringTransactionService.applyRecurringTransaction(recurring, in: modelContext)
    }
    
    // Deletes only the recurring rule itself.
    // Previously generated real transactions are not affected.
    private func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
        modelContext.delete(recurring)
    }
}

#Preview {
    RecurringTransactionsListView()
}
