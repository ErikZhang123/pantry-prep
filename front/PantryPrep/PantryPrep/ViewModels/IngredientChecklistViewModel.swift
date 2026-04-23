import Foundation

@Observable
@MainActor
final class IngredientChecklistViewModel {
    var ingredients: [MergedIngredient] = []
    var isLoading = false
    var errorMessage: String?

    private let service: IngredientGenerationService

    init(service: IngredientGenerationService = IngredientGenerationService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let dtos = try await service.generate(
                recipes: ["Tomato Scrambled Eggs", "Egg Fried Rice"],
                servings: 2,
                includePantryStaples: true
            )
            ingredients = IngredientMerger.merge(dtos)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleOwned(_ id: MergedIngredient.ID) {
        guard let idx = ingredients.firstIndex(where: { $0.id == id }) else { return }
        ingredients[idx].owned.toggle()
    }

    func delete(_ id: MergedIngredient.ID) {
        ingredients.removeAll { $0.id == id }
    }

    func update(_ updated: MergedIngredient) {
        guard let idx = ingredients.firstIndex(where: { $0.id == updated.id }) else { return }
        ingredients[idx] = updated
    }

    func resetChecks() {
        for idx in ingredients.indices {
            ingredients[idx].owned = false
        }
    }
}
