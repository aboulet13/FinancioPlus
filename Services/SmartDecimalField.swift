//
//  SmartDecimalField.swift
//  Financio
//
//  Created by Ariane on 28/05/2026.
//

import SwiftUI

struct SmartDecimalField: View {
    var title: String
    @Binding var value: Double?
    var allowNegative: Bool
    
    // We use a String internally so the user can type freely without the text jumping around
    @State private var textString: String = ""
    
    // Initializer for optional Doubles (like balance: Double?)
    init(_ title: String, value: Binding<Double?>, allowNegative: Bool = false) {
        self.title = title
        self._value = value
        self.allowNegative = allowNegative
    }
    
    // Initializer for non-optional Doubles (like amount: Double)
    init(_ title: String, value: Binding<Double>, allowNegative: Bool = false) {
        self.title = title
        // Maps the non-optional Double to our optional binding
        self._value = Binding<Double?>(
            get: { value.wrappedValue },
            set: { value.wrappedValue = $0 ?? 0.0 }
        )
        self.allowNegative = allowNegative
    }
    
    var body: some View {
        TextField(title, text: $textString)
            // Show the punctuation keyboard if we need the minus sign, otherwise standard decimal pad
            .keyboardType(allowNegative ? .numbersAndPunctuation : .decimalPad)
            .onChange(of: textString) { _, newValue in
                // 1. Normalize the string: convert commas to dots so Swift can do the math
                let normalizedString = newValue.replacingOccurrences(of: ",", with: ".")
                
                // 2. Try to parse the clean string into a Double
                if let parsedDouble = Double(normalizedString) {
                    value = parsedDouble
                } else if normalizedString.isEmpty || normalizedString == "-" {
                    // Allow the field to be empty, or allow the user to type a minus sign to start a debt
                    value = nil
                }
            }
            .onAppear {
                // When the view loads (like in an Edit view), format the existing database number nicely
                if let val = value, val != 0 {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.usesGroupingSeparator = false // Prevents spaces/commas in thousands that break editing
                    formatter.maximumFractionDigits = 2
                    
                    if let formatted = formatter.string(from: NSNumber(value: val)) {
                        textString = formatted
                    }
                }
            }
    }
}
