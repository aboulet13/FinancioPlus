//
//  IconPickerView.swift
//  Financio
//
//  Created by Ariane on 22/05/2026.
//

import SwiftUI

struct IconPickerView: View {
    // We use a Binding so when the user taps an icon,
    // it updates the variable in the Add/Edit Category view instantly.
    @Binding var selectedIcon: String
    
    @Environment(\.dismiss) private var dismiss
    
    // A curated list of great SF Symbols for a budgeting app
    let availableIcons = [
        "tag.fill", "cart.fill", "basket.fill", "creditcard.fill", "house.fill",
        "car.fill", "bus.fill", "airplane", "fuelpump.fill", "fork.knife",
        "cup.and.saucer.fill", "takeoutbox.fill", "tv.fill", "gamecontroller.fill",
        "display", "cross.case.fill", "heart.fill", "pills.fill", "pawprint.fill",
        "leaf.fill", "flame.fill", "drop.fill", "bolt.fill", "gift.fill",
        "briefcase.fill", "graduationcap.fill", "book.fill", "tram.fill",
        "wrench.and.screwdriver.fill", "hammer.fill", "party.popper.fill",
        "tshirt.fill", "shoe.fill", "ticket.fill", "popcorn.fill"
    ]
    
    // Creates a grid that automatically fits as many columns as possible
    let columns = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableIcons, id: \.self) { iconName in
                        Image(systemName: iconName)
                            .font(.title)
                            .frame(width: 50, height: 50)
                            // Highlight the currently selected icon
                            .background(selectedIcon == iconName ? Color.accentColor.opacity(0.2) : Color.clear)
                            .foregroundStyle(selectedIcon == iconName ? Color.accentColor : Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                // Add a subtle native click when they select!
                                HapticManager.playImpact(style: .light)
                                selectedIcon = iconName
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
