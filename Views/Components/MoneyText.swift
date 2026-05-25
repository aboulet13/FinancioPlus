//
//  MoneyText.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI

struct MoneyText: View {
    
    // Reads the selected app currency from persistent app settings.
<<<<<<< HEAD
    // We tell MoneyText to read the currency from the shared App Group folder
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"
=======
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode = "USD"
    
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    // The numeric amount to display as money.
    let amount: Double
    
    var body: some View {
        Text(amount, format: .currency(code: selectedCurrencyCode))
    }
}

#Preview {
    VStack(spacing: 12) {
        MoneyText(amount: 1234.56)
        MoneyText(amount: -78.90)
    }
    .padding()
}
