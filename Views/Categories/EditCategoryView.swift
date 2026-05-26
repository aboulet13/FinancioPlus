//
//  EditCategoryView.swift
//  Financio
//
//  Created by Ariane Boulet on 13/04/2026.
//

import SwiftUI
import SwiftData

struct EditCategoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // The category being edited.
    let category: Category
    
    // Form state initialized from the current category values.
    @State private var name: String
    @State private var selectedKind: CategoryKind
    @State private var iconName: String
    
    // We use a Color object instead of a String
    @State private var selectedColor: Color
    @State private var showingIconPicker = false
    
    // Custom initializer to pre-fill the form.
    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name)
        _selectedKind = State(initialValue: category.kind)
        _iconName = State(initialValue: category.iconName)
        
        // Translate the saved Hex string back into a SwiftUI Color so the wheel loads correctly!
        _selectedColor = State(initialValue: Color(hex: category.colorHex))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Category Name", text: $name)
                    
                    Picker("Category Type", selection: $selectedKind) {
                        ForEach(CategoryKind.allCases, id: \.self) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    
                    // Visual Icon Selector
                    HStack {
                        Text("Icon")
                        Spacer()
                        
                        // Show the actual image they selected
                        Image(systemName: iconName)
                            .font(.title3)
                            .foregroundStyle(selectedColor)
                            .padding(8)
                            // The icon preview now updates dynamically to match the color wheel!
                            .background(selectedColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .contentShape(Rectangle()) // Makes the whole row tappable, not just the text
                    .onTapGesture {
                        showingIconPicker = true
                    }
                    // Present the grid when tapped
                    .sheet(isPresented: $showingIconPicker) {
                        IconPickerView(selectedIcon: $iconName)
                            .presentationDetents([.medium, .large]) // Makes it a nice half-sheet
                    }
                    
                    // Apple's native color wheel!
                    ColorPicker("Category Color", selection: $selectedColor, supportsOpacity: false)
                    
                    // REMOVED: TextFields for Icon Name and Color Hex have been completely removed!
                }
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        updateCategory()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Basic validation for category editing.
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Saves the updated category values.
    private func updateCategory() {
        guard isFormValid else { return }
        
        // 1. Force Xcode to read the State variable as a raw Color object
        let safeColor: Color = selectedColor
        
        // 2. Call the custom extension to translate it back to a database string
        let hexString = safeColor.toHex() ?? "#007AFF"
        
        // 3. Save the newly updated values to the live database object
        category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        category.kind = selectedKind
        category.iconName = iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "tag" : iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        category.colorHex = hexString
        
        dismiss()
    }
}

#Preview {
    Text("EditCategoryView Preview")
}
