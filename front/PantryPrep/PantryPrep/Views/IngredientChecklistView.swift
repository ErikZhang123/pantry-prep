import SwiftUI

struct IngredientChecklistView: View {
    @State private var viewModel = IngredientChecklistViewModel()
    @State private var editing: MergedIngredient?

    var body: some View {
        content
            .navigationTitle("Checklist")
            .toolbar { toolbarContent }
            .task {
                if viewModel.ingredients.isEmpty && !viewModel.isLoading {
                    await viewModel.load()
                }
            }
            .sheet(item: $editing) { original in
                EditIngredientSheet(original: original) { updated in
                    viewModel.update(updated)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading ingredients…")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Couldn't load",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else if viewModel.ingredients.isEmpty {
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
                            IngredientRowView(
                                ingredient: ingredient,
                                onToggleOwned: { viewModel.toggleOwned(ingredient.id) },
                                onEdit: { editing = ingredient }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.delete(ingredient.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    viewModel.resetChecks()
                } label: {
                    Label("Reset checks", systemImage: "arrow.counterclockwise")
                }
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(viewModel.ingredients.isEmpty && !viewModel.isLoading)
        }
    }

    private var groupedByCategory: [(key: IngredientCategory, value: [MergedIngredient])] {
        let dict = Dictionary(grouping: viewModel.ingredients) { $0.category }
        return IngredientCategory.allCases.compactMap { cat in
            guard let items = dict[cat], !items.isEmpty else { return nil }
            return (key: cat, value: items)
        }
    }
}

#Preview {
    NavigationStack { IngredientChecklistView() }
}
