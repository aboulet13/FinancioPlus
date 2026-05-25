//
//  SheetManager.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import SwiftUI

// 1. Define all the possible "Quick Add" actions
enum QuickAddAction: Identifiable {
    case transaction
    case account
    case budget
    case savingsGoal
    case recurringTransaction
    
    // Required by SwiftUI sheets to know which one is open
    var id: Int { self.hashValue }
}

// 2. Create the observable manager that the whole app can see
@Observable
class SheetManager {
    var activeSheet: QuickAddAction? = nil
}
