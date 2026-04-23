import SwiftUI

struct IngredientChecklistView: View {
    @State private var ingredients: [MergedIngredient] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading ingredients…")
            } else if let errorMessage {
                ContentUnavailableView(
                    "Couldn't load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if ingredients.isEmpty {
                ContentUnavailableView(
                    "No ingredients yet",
                    systemImage: "checklist",
                    description: Text("Generate some from the Home tab.")
                )
            } else {
                List {
                    ForEach(groupedByCategory, id: \.key) { category, items in
                        Section(category.displayName) {
                            ForEach(items) { ingredient in
                                IngredientRowView(ingredient: ingredient)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Checklist")
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let dtos = try await IngredientGenerationService().generate(
                recipes: ["Tomato Scrambled Eggs", "Egg Fried Rice"],
                servings: 2,
                includePantryStaples: true
            )
            ingredients = IngredientMerger.merge(dtos)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private var groupedByCategory: [(key: IngredientCategory, value: [MergedIngredient])] {
        let dict = Dictionary(grouping: ingredients) { $0.category }
        return IngredientCategory.allCases.compactMap { cat in
            guard let items = dict[cat], !items.isEmpty else { return nil }
            return (key: cat, value: items)
        }
    }
}

#Preview {
    NavigationStack { IngredientChecklistView() }
}
