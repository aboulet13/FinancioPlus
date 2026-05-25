//
//  BiometricAuthManager.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//

import Foundation
import LocalAuthentication
import SwiftUI

@Observable
class BiometricAuthManager {
    
    // Tracks whether the app is currently unlocked
    var isUnlocked = false
    
    // Holds any error messages to display to the user
    var errorMessage = ""
    
    // The main function that asks the iPhone to scan a face or fingerprint
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // 1. Check if the device is CAPABLE of biometrics (e.g., has a Face ID camera)
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Unlock Financio to view your secure financial data."
            
            // 2. Ask the hardware to perform the scan
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                // 3. Hardware callbacks happen in the background. We MUST route the UI
                // update back to the Main Thread.
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.errorMessage = authenticationError?.localizedDescription ?? "Authentication failed."
                    }
                }
            }
        } else {
            // Fallback if the device doesn't have Face ID or it is disabled
            self.errorMessage = "Biometrics are unavailable on this device."
        }
    }
    
    // Helper to manually lock the app
    func lockApp() {
        isUnlocked = false
    }
}
