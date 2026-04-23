import Foundation

struct IngredientDTO: Codable, Hashable, Identifiable {
    let id: String
    let displayName: String
    let canonicalName: String
    let quantity: Double?
    let unit: String?
    let category: IngredientCategory
    let optional: Bool
    let pantryStaple: Bool
    let recipeName: String
}

struct GenerateRequest: Codable {
    let recipes: [String]
    let servings: Int
    let includePantryStaples: Bool
}

struct GenerateResponse: Codable {
    let ingredients: [IngredientDTO]
}
