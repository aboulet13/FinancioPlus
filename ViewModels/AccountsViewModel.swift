//
//  AccountsViewModel.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

<<<<<<< HEAD
import Foundation

// The ViewModel for our Accounts list.
// It separates the raw SwiftData models into logical, ready-to-display arrays.
struct AccountsViewModel {
    
    // 1. RAW INGREDIENTS
    let accounts: [Account]
    
    // 2. COMPUTED DATA
    // Returns only accounts that the user is actively using.
    var activeAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == false
        }
    }
    
    // Returns accounts the user has hidden/archived.
    var archivedAccounts: [Account] {
        accounts.filter { account in
            account.isArchived == true
        }
    }
    
    // Bonus calculation: The total balance of all active accounts.
    // (A great piece of data that is now easy to test mathematically!)
    var totalActiveBalance: Double {
        activeAccounts.reduce(0) { partialResult, account in
            partialResult + account.balance
        }
    }
}
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
