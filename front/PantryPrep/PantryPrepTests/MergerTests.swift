import Testing
@testable import PantryPrep

struct MergerTests {
    private func dto(
        id: String = "1",
        display: String = "Eggs",
        canonical: String = "egg",
        qty: Double? = 1,
        unit: String? = "pcs",
        category: IngredientCategory = .protein,
        optional: Bool = false,
        pantryStaple: Bool = false,
        recipe: String = "Recipe A"
    ) -> IngredientDTO {
        IngredientDTO(
            id: id, displayName: display, canonicalName: canonical,
            quantity: qty, unit: unit, category: category,
            optional: optional, pantryStaple: pantryStaple,
            recipeName: recipe
        )
    }

    @Test func emptyInputReturnsEmpty() {
        #expect(IngredientMerger.merge([]).isEmpty)
    }

    @Test func mergesDuplicatesWithSameUnit() {
        let merged = IngredientMerger.merge([
            dto(id: "1", display: "Eggs", canonical: "eggs", qty: 4, unit: "pcs", recipe: "A"),
            dto(id: "2", display: "Egg", canonical: "egg", qty: 2, unit: "pcs", recipe: "B"),
        ])
        #expect(merged.count == 1)
        #expect(merged[0].totalQuantity == 6)
        #expect(merged[0].unit == "pcs")
        #expect(merged[0].needsReview == false)
        #expect(merged[0].sources.count == 2)
    }

    @Test func flagsUnitConflict() {
        let merged = IngredientMerger.merge([
            dto(id: "1", canonical: "green onion", qty: 1, unit: "bunch", category: .vegetable, recipe: "A"),
            dto(id: "2", canonical: "green onion", qty: 1, unit: "stalk", category: .vegetable, recipe: "B"),
        ])
        #expect(merged.count == 1)
        #expect(merged[0].needsReview == true)
        #expect(merged[0].totalQuantity == nil)
        #expect(merged[0].unit == nil)
        #expect(merged[0].sources.count == 2)
    }

    @Test func preservesMissingQuantity() {
        let merged = IngredientMerger.merge([
            dto(canonical: "salt", qty: nil, unit: "pinch", category: .spice, pantryStaple: true),
            dto(id: "2", canonical: "salt", qty: nil, unit: "pinch", category: .spice, pantryStaple: true, recipe: "B"),
        ])
        #expect(merged.count == 1)
        #expect(merged[0].totalQuantity == nil)
        #expect(merged[0].unit == "pinch")
    }

    @Test func appliesNormalizationBeforeGrouping() {
        let merged = IngredientMerger.merge([
            dto(id: "1", canonical: "scallions", qty: 1, unit: "bunch", category: .vegetable, recipe: "A"),
            dto(id: "2", canonical: "green onion", qty: 1, unit: "bunch", category: .vegetable, recipe: "B"),
        ])
        #expect(merged.count == 1)
        #expect(merged[0].canonicalName == "green onion")
        #expect(merged[0].totalQuantity == 2)
    }

    @Test func optionalOnlyTrueIfAllSourcesOptional() {
        let merged = IngredientMerger.merge([
            dto(id: "1", canonical: "basil", optional: true, recipe: "A"),
            dto(id: "2", canonical: "basil", optional: false, recipe: "B"),
        ])
        #expect(merged[0].optional == false)
    }

    @Test func pantryStapleTrueIfAnySourceMarked() {
        let merged = IngredientMerger.merge([
            dto(id: "1", canonical: "oil", pantryStaple: true, recipe: "A"),
            dto(id: "2", canonical: "oil", pantryStaple: false, recipe: "B"),
        ])
        #expect(merged[0].pantryStaple == true)
    }
}
