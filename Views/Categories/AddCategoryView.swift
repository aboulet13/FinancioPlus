//
//  AddCategoryView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    
    // Gives access to the SwiftData model context for saving the new category.
    @Environment(\.modelContext) private var modelContext
    
    // Lets us dismiss the sheet after saving or canceling.
    @Environment(\.dismiss) private var dismiss
    
    // User-entered category name.
    @State private var name = ""
    
    // User-selected category kind.
    @State private var selectedKind: CategoryKind = .expense
    
    // User-entered SF Symbol name.
    @State private var iconName = "tag"
    
<<<<<<< HEAD
    // We default to our app's beautiful Accent Color!
    @State private var selectedColor: Color = .accentColor
    
    @State private var showingIconPicker = false
    
    // An optional callback that passes the newly created category back to whoever opened this sheet.
    // It defaults to nil, so it won't break your CategoriesListView!
    var onSave: ((Category) -> Void)? = nil
    
    // Custom initializer so the parent view can tell us whether we are making an Income or Expense
    init(defaultKind: CategoryKind = .expense, onSave: ((Category) -> Void)? = nil) {
        // We use the underscore (_selectedKind) to initialize the State wrapper directly
        _selectedKind = State(initialValue: defaultKind)
        self.onSave = onSave
    }
=======
    // User-entered color hex string.
    @State private var colorHex = "#007AFF"
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
    
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
                    
<<<<<<< HEAD
                    // Visual Icon Selector
                    HStack {
                        Text("Icon")
                        Spacer()
                        
                        // Show the actual image selected
                        Image(systemName: iconName)
                            .font(.title3)
                            .foregroundStyle(selectedColor)
                            .padding(8)
                            .background(Color(selectedColor).opacity(0.15))
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
                    // We disable opacity because categories should be solid colors.
                    ColorPicker("Category Color", selection: $selectedColor, supportsOpacity: false)
=======
                    // Text field for SF Symbol name.
                    // Example: "cart", "house", "fork.knife"
                    TextField("Icon Name", text: $iconName)
                    
                    // Text field for color in hex format.
                    // We keep this simple for now.
                    TextField("Color Hex", text: $colorHex)
                        .textInputAutocapitalization(.never)
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
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
<<<<<<< HEAD
        // 1. Force Xcode to read the State variable as a raw Color object
        let safeColor: Color = selectedColor
        
        // 2. Call the custom extension on the safe variable
        let hexString = safeColor.toHex() ?? "007AFF"
        
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        let newCategory = Category(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            kind: selectedKind,
            iconName: iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "tag" : iconName,
<<<<<<< HEAD
            colorHex: hexString,
=======
            colorHex: colorHex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "#007AFF" : colorHex,
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
            isSystem: false
        )
        
        modelContext.insert(newCategory)
<<<<<<< HEAD
        
        // Hand the newly created object back to the parent view!
        onSave?(newCategory)
        
=======
>>>>>>> 74d97b81f555e56974bd3e08d497b3cb8eab8b38
        dismiss()
    }
}

#Preview {
    AddCategoryView()
}
