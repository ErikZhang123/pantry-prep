import Testing
@testable import PantryPrep

struct NormalizerTests {
    @Test func lowercasesAndTrims() {
        #expect(IngredientNormalizer.normalize("  Tomato  ") == "tomato")
        #expect(IngredientNormalizer.normalize("EGG") == "egg")
    }

    @Test func singularizesCommonPlurals() {
        #expect(IngredientNormalizer.normalize("eggs") == "egg")
        #expect(IngredientNormalizer.normalize("tomatoes") == "tomato")
        #expect(IngredientNormalizer.normalize("potatoes") == "potato")
        #expect(IngredientNormalizer.normalize("onions") == "onion")
        #expect(IngredientNormalizer.normalize("carrots") == "carrot")
    }

    @Test func handlesIesPlurals() {
        #expect(IngredientNormalizer.normalize("berries") == "berry")
        #expect(IngredientNormalizer.normalize("cherries") == "cherry")
    }

    @Test func preservesWordsEndingInProtectedSuffixes() {
        #expect(IngredientNormalizer.normalize("asparagus") == "asparagus")
        #expect(IngredientNormalizer.normalize("grass") == "grass")
        #expect(IngredientNormalizer.normalize("basis") == "basis")
    }

    @Test func appliesSynonymMap() {
        #expect(IngredientNormalizer.normalize("scallions") == "green onion")
        #expect(IngredientNormalizer.normalize("scallion") == "green onion")
        #expect(IngredientNormalizer.normalize("spring onion") == "green onion")
        #expect(IngredientNormalizer.normalize("Spring Onions") == "green onion")
    }

    @Test func idempotent() {
        let once = IngredientNormalizer.normalize("Tomatoes")
        let twice = IngredientNormalizer.normalize(once)
        #expect(once == twice)
    }
}
