//
//  AccountGroup.swift
//  Financio
//
//  Created by Ariane on 26/05/2026.
//

import Foundation
import SwiftData

@Model
final class AccountGroup {
    
    var id: UUID = UUID()
    var name: String
    
    // The relationship: One group can hold many accounts.
    // 'cascade' means if you delete the "Chase Bank" group, all accounts inside it are deleted too.
    @Relationship(deleteRule: .cascade, inverse: \Account.group)
    var accounts: [Account]? = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    // Computed property to automatically sum up the balances of all sub-accounts
    var totalBalance: Double {
        // If accounts is nil, default to empty array, then sum the balances
        return accounts?.reduce(0) { $0 + $1.balance } ?? 0.0
    }
}
