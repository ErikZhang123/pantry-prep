import Foundation

enum MockIngredientService {
    static func generate(
        recipes: [String],
        servings: Int,
        includePantryStaples: Bool
    ) async -> [IngredientDTO] {
        if includePantryStaples {
            return sampleDTOs
        }
        return sampleDTOs.filter { !$0.pantryStaple }
    }

    static let sampleDTOs: [IngredientDTO] = [
        IngredientDTO(
            id: "1", displayName: "Eggs", canonicalName: "eggs",
            quantity: 4, unit: "pcs", category: .protein,
            optional: false, pantryStaple: false,
            recipeName: "Tomato Scrambled Eggs"
        ),
        IngredientDTO(
            id: "2", displayName: "Tomato", canonicalName: "tomatoes",
            quantity: 2, unit: "pcs", category: .vegetable,
            optional: false, pantryStaple: false,
            recipeName: "Tomato Scrambled Eggs"
        ),
        IngredientDTO(
            id: "3", displayName: "Green Onion", canonicalName: "green onion",
            quantity: 1, unit: "bunch", category: .vegetable,
            optional: false, pantryStaple: false,
            recipeName: "Tomato Scrambled Eggs"
        ),
        IngredientDTO(
            id: "4", displayName: "Salt", canonicalName: "salt",
            quantity: nil, unit: "pinch", category: .spice,
            optional: false, pantryStaple: true,
            recipeName: "Tomato Scrambled Eggs"
        ),
        IngredientDTO(
            id: "5", displayName: "Cooking Oil", canonicalName: "cooking oil",
            quantity: 1, unit: "tbsp", category: .pantry,
            optional: false, pantryStaple: true,
            recipeName: "Tomato Scrambled Eggs"
        ),

        IngredientDTO(
            id: "6", displayName: "Egg", canonicalName: "egg",
            quantity: 2, unit: "pcs", category: .protein,
            optional: false, pantryStaple: false,
            recipeName: "Egg Fried Rice"
        ),
        IngredientDTO(
            id: "7", displayName: "Rice", canonicalName: "rice",
            quantity: 200, unit: "g", category: .grain,
            optional: false, pantryStaple: false,
            recipeName: "Egg Fried Rice"
        ),
        IngredientDTO(
            id: "8", displayName: "Scallions", canonicalName: "scallions",
            quantity: 1, unit: "stalk", category: .vegetable,
            optional: false, pantryStaple: false,
            recipeName: "Egg Fried Rice"
        ),
        IngredientDTO(
            id: "9", displayName: "Soy Sauce", canonicalName: "soy sauce",
            quantity: 2, unit: "tsp", category: .condiment,
            optional: false, pantryStaple: false,
            recipeName: "Egg Fried Rice"
        ),
        IngredientDTO(
            id: "10", displayName: "Salt", canonicalName: "salt",
            quantity: nil, unit: "pinch", category: .spice,
            optional: false, pantryStaple: true,
            recipeName: "Egg Fried Rice"
        ),
        IngredientDTO(
            id: "11", displayName: "Sesame Oil", canonicalName: "sesame oil",
            quantity: 1, unit: "tsp", category: .condiment,
            optional: true, pantryStaple: false,
            recipeName: "Egg Fried Rice"
        ),
    ]
}
