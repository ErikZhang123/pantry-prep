import Testing
import Foundation
@testable import PantryPrep

@MainActor
struct IngredientChecklistViewModelTests {
    private func sampleIngredient(
        display: String = "Eggs",
        category: IngredientCategory = .protein,
        owned: Bool = false
    ) -> MergedIngredient {
        MergedIngredient(
            id: UUID(),
            displayName: display,
            canonicalName: display.lowercased(),
            totalQuantity: 2,
            unit: "pcs",
            category: category,
            optional: false,
            pantryStaple: false,
            owned: owned,
            sources: [],
            needsReview: false
        )
    }

    @Test func toggleOwnedFlipsState() {
        let vm = IngredientChecklistViewModel()
        let ingredient = sampleIngredient()
        vm.ingredients = [ingredient]

        vm.toggleOwned(ingredient.id)
        #expect(vm.ingredients[0].owned == true)

        vm.toggleOwned(ingredient.id)
        #expect(vm.ingredients[0].owned == false)
    }

    @Test func toggleOwnedWithUnknownIdIsNoop() {
        let vm = IngredientChecklistViewModel()
        vm.ingredients = [sampleIngredient()]
        vm.toggleOwned(UUID())
        #expect(vm.ingredients[0].owned == false)
    }

    @Test func deleteRemovesMatchingIngredient() {
        let vm = IngredientChecklistViewModel()
        let a = sampleIngredient(display: "Eggs")
        let b = sampleIngredient(display: "Tomato", category: .vegetable)
        vm.ingredients = [a, b]

        vm.delete(a.id)
        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].id == b.id)
    }

    @Test func updateReplacesIngredient() {
        let vm = IngredientChecklistViewModel()
        let original = sampleIngredient(display: "Eggs")
        vm.ingredients = [original]

        var modified = original
        modified.displayName = "Eggs (organic)"
        modified.totalQuantity = 6
        vm.update(modified)

        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].displayName == "Eggs (organic)")
        #expect(vm.ingredients[0].totalQuantity == 6)
    }

    @Test func updateUnknownIdIsNoop() {
        let vm = IngredientChecklistViewModel()
        let original = sampleIngredient(display: "Eggs")
        vm.ingredients = [original]

        var rogue = sampleIngredient(display: "Rogue")
        rogue.displayName = "Rogue"
        vm.update(rogue)

        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].displayName == "Eggs")
    }

    @Test func resetChecksClearsAllOwned() {
        let vm = IngredientChecklistViewModel()
        vm.ingredients = [
            sampleIngredient(display: "Eggs", owned: true),
            sampleIngredient(display: "Tomato", category: .vegetable, owned: true),
            sampleIngredient(display: "Salt", category: .spice, owned: false),
        ]

        vm.resetChecks()
        #expect(vm.ingredients.allSatisfy { $0.owned == false })
    }
}
