//
//  LockScreenView.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//

import SwiftUI

struct LockScreenView: View {
    
    // We pass in the manager so we can trigger the authenticate() function
    var authManager: BiometricAuthManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Financio is Locked")
                .font(.title)
                .bold()
            
            Text("Your financial data is protected.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                authManager.authenticate()
            } label: {
                Text("Unlock with Face ID")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // A solid background prevents the user's data from peeking through
        .background(Color(UIColor.systemBackground))
        // Automatically try to authenticate as soon as this screen appears
        .onAppear {
            authManager.authenticate()
        }
    }
}
