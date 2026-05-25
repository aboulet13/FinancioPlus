//
//  CurrencyManager.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
}

struct CurrencyManager {
    
    // A list of currency options available in the app.
    // We keep this short for MVP, but you can add more later.
    static let supportedCurrencies: [CurrencyOption] = [
        CurrencyOption(code: "USD", name: "US Dollar", symbol: "$"),
        CurrencyOption(code: "EUR", name: "Euro", symbol: "€"),
        CurrencyOption(code: "GBP", name: "British Pound", symbol: "£"),
        CurrencyOption(code: "CAD", name: "Canadian Dollar", symbol: "CA$"),
        CurrencyOption(code: "AUD", name: "Australian Dollar", symbol: "A$"),
        CurrencyOption(code: "JPY", name: "Japanese Yen", symbol: "¥")
    ]
}
