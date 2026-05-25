//
//  AddCategoryView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    
    // Gives access to the SwiftData model context and dismiss action.
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 1. FORM STATE
    @State private var name = ""
    @State private var selectedKind: CategoryKind = .expense
    @State private var iconName = "tag"
    @State private var selectedColor: Color = .accentColor
    @State private var showingIconPicker = false
    
    // An optional callback that passes the newly created category back to whoever opened this sheet.
    var onSave: ((Category) -> Void)? = nil
    
    // Custom initializer so the parent view can tell us whether we are making an Income or Expense
    init(defaultKind: CategoryKind = .expense, onSave: ((Category) -> Void)? = nil) {
        // We use the underscore (_selectedKind) to initialize the State wrapper directly
        _selectedKind = State(initialValue: defaultKind)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    
                    // Text field for category name.
                    TextField("Category Name", text: $name)
                    
                    // Picker to choose whether the category is for income or expense.
                    Picker("Category Type", selection: $selectedKind) {
                        ForEach(CategoryKind.allCases, id: \.self) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    
                    // Visual Icon Selector
                    HStack {
                        Text("Icon")
                        Spacer()
                        
                        // Show the actual image selected
                        Image(systemName: iconName)
                            .font(.title3)
                            .foregroundStyle(selectedColor)
                            .padding(8)
                            .background(selectedColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .contentShape(Rectangle()) // Makes the whole row tappable
                    .onTapGesture {
                        showingIconPicker = true
                    }
                    // Present the grid when tapped
                    .sheet(isPresented: $showingIconPicker) {
                        IconPickerView(selectedIcon: $iconName)
                            .presentationDetents([.medium, .large]) // Makes it a nice half-sheet
                    }
                    
                    // Apple's native color wheel!
                    // We disable opacity because categories should be solid colors.
                    ColorPicker("Category Color", selection: $selectedColor, supportsOpacity: false)
                }
            }
            .navigationTitle("Add Category")
            .toolbar {
                // Cancel button closes the sheet without saving.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save button creates and inserts the category.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // Creates a new category and inserts it into SwiftData.
    private func saveCategory() {
        // 1. Force Xcode to read the State variable as a raw Color object
        let safeColor: Color = selectedColor
        
        // 2. Call the custom extension on the safe variable
        let hexString = safeColor.toHex() ?? "007AFF"
        
        let newCategory = Category(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            kind: selectedKind,
            iconName: iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "tag" : iconName,
            colorHex: hexString, // Using our translated hex string!
            isSystem: false
        )
        
        modelContext.insert(newCategory)
        
        // Hand the newly created object back to the parent view!
        onSave?(newCategory)
        
        dismiss()
    }
}

#Preview {
    AddCategoryView()
}
