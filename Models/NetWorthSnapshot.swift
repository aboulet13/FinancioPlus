//
//  NetWorthSnapshot.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import Foundation
import SwiftData

@Model
final class NetWorthSnapshot {
    var id: UUID
    var date: Date
    var amount: Double
    
    init(date: Date = Date(), amount: Double) {
        self.id = UUID()
        
        // We strip the hours/minutes/seconds to ensure the snapshot is just "The Day"
        let startOfDay = Calendar.current.startOfDay(for: date)
        self.date = startOfDay
        
        self.amount = amount
    }
}
