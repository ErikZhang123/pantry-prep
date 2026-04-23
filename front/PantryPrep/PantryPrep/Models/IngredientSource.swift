import Foundation

struct IngredientSource: Hashable, Codable {
    let recipeName: String
    let quantity: Double?
    let unit: String?
}
