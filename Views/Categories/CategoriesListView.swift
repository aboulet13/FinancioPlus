//
//  CategoriesListView.swift
//  Financio
//
//  Created by Ariane Boulet on 12/04/2026.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var isShowingAddCategory = false
    
    // Stores the category currently selected for editing.
    @State private var selectedCategory: Category?
    
    // NEW: Stores the category the user is about to permanently delete.
    @State private var categoryPendingDelete: Category?
    
    var body: some View {
        NavigationStack {
            Group {
                if categories.isEmpty {
                    ContentUnavailableView(
                        "No Categories Yet",
                        systemImage: "tag",
                        description: Text("Add categories to organize your income and expenses.")
                    )
                } else {
                    List {
                        ForEach(categories) { category in
                            HStack(spacing: 16) {
                                
                                // NEW: The icon now uses your custom color!
                                Image(systemName: category.iconName)
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: category.colorHex))
                                    .frame(width: 32, height: 32)
                                    // Use our Color+Hex extension to read the database color
                                    .background(Color(hex: category.colorHex).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                    
                                    Text(category.kind.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCategory = category
                            }
                            // NEW: Swipe to delete action
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    categoryPendingDelete = category
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddCategory) {
                AddCategoryView()
            }
            .sheet(item: $selectedCategory) { category in
                EditCategoryView(category: category)
            }
            // NEW: Delete Confirmation Dialog
            .confirmationDialog(
                "Permanently delete this category?",
                isPresented: Binding(
                    get: { categoryPendingDelete != nil },
                    set: { newValue in
                        if newValue == false {
                            categoryPendingDelete = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Category", role: .destructive) {
                    if let categoryPendingDelete {
                        deleteCategory(categoryPendingDelete)
                        self.categoryPendingDelete = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    categoryPendingDelete = nil
                }
            } message: {
                Text("Deleting this category will remove it permanently. Any past transactions tied to this category will lose their categorization.")
            }
        }
    }
    
    // NEW: Deletes the category from the SwiftData context.
    private func deleteCategory(_ category: Category) {
        modelContext.delete(category)
    }
}

#Preview {
    CategoriesListView()
}
