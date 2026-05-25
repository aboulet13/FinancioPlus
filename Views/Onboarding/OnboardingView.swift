//
//  OnboardingView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // Marks whether the user has finished onboarding.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Form state for the first account.
    @State private var accountName = ""
    @State private var selectedType: AccountType = .checking
    @State private var startingBalance = 0.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Welcome to Financio")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Track your money, set budgets, and understand your spending with clarity.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                Form {
                    Section("Create Your First Account") {
                        TextField("Account Name", text: $accountName)
                        
                        Picker("Account Type", selection: $selectedType) {
                            ForEach(AccountType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        
                        TextField("Starting Balance", value: $startingBalance, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                .frame(maxHeight: 250)
                
                Button {
                    completeOnboarding()
                } label: {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .disabled(accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // Creates the user's first account and marks onboarding as complete.
    private func completeOnboarding() {
        let firstAccount = Account(
            name: accountName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType,
            balance: startingBalance
        )
        
        modelContext.insert(firstAccount)
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
}
