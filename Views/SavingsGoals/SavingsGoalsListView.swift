//
//  SavingsGoalsListView.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//


import SwiftUI
import SwiftData

struct SavingsGoalsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. FETCH RAW DATA
    @Query(sort: \SavingsGoals.title) private var goals: [SavingsGoals]
    
    // 2. UI STATE
    @State private var isShowingAddGoal = false
    @State private var selectedGoal: SavingsGoals?
    @State private var goalPendingDeletion: SavingsGoals?
    
    // 3. INJECT INTO VIEW MODEL
    private var viewModel: SavingsGoalsViewModel {
        SavingsGoalsViewModel(goals: goals)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if goals.isEmpty {
                    ContentUnavailableView(
                        "No Savings Goals",
                        systemImage: "target",
                        description: Text("Create a goal to start saving for a vacation, a car, or an emergency fund.")
                    )
                } else {
                    List {
                        ForEach(goals) { goal in
                            goalRow(for: goal)
                                .onTapGesture {
                                    // Tapping opens the edit sheet
                                    selectedGoal = goal
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        goalPendingDeletion = goal
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Savings Goals")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // We will create AddSavingsGoalView and EditSavingsGoalView in the next step!
            .sheet(isPresented: $isShowingAddGoal) { AddSavingsGoalView() }
            .sheet(item: $selectedGoal) { goal in EditSavingsGoalView(goal: goal) }
            .confirmationDialog(
                "Delete this goal?",
                isPresented: Binding(
                    get: { goalPendingDeletion != nil },
                    set: { if !$0 { goalPendingDeletion = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Goal", role: .destructive) {
                    if let goalToDelete = goalPendingDeletion {
                        modelContext.delete(goalToDelete)
                        goalPendingDeletion = nil
                    }
                }
                Button("Cancel", role: .cancel) { goalPendingDeletion = nil }
            } message: {
                Text("This will permanently remove your goal tracking. Your actual account balances will remain unchanged.")
            }
        }
    }
    
    // Reusable UI Component for drawing a single goal
    @ViewBuilder
    private func goalRow(for goal: SavingsGoals) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header: Icon, Title, and Percentage
            HStack {
                Image(systemName: goal.iconName)
                    .foregroundStyle(.white)
                    .padding(8)
                    // Currently using a hardcoded color for safety, we'll implement Hex conversion later if needed
                    .background(Color.blue)
                    .clipShape(Circle())
                
                Text(goal.title)
                    .font(.headline)
                
                Spacer()
                
                Text(viewModel.progressPercentageText(for: goal))
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
            }
            
            // Progress Bar
            ProgressView(value: viewModel.progressRatio(for: goal))
                .tint(.blue)
            
            // Footer: Current vs Target amounts, and Days Remaining
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: goal.currentAmount)
                        .font(.subheadline)
                        .bold()
                }
                
                Spacer()
                
                if let daysLeft = viewModel.daysRemainingText(for: goal) {
                    Text(daysLeft)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    MoneyText(amount: goal.targetAmount)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    SavingsGoalsListView()
}
