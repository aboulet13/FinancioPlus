//
//  MoneyText.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI

struct MoneyText: View {
    
    // Reads the selected app currency from persistent app settings.
    // We tell MoneyText to read the currency from the shared App Group folder
    // so that Home Screen Widgets can display the correct currency too!
    @AppStorage("selectedCurrencyCode", store: UserDefaults(suiteName: "group.com.ariane.Financio"))
    private var selectedCurrencyCode = "USD"
    
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
