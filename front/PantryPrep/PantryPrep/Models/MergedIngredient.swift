import Foundation

struct MergedIngredient: Identifiable, Hashable {
    let id: UUID
    var displayName: String
    var canonicalName: String
    var totalQuantity: Double?
    var unit: String?
    var category: IngredientCategory
    var optional: Bool
    var pantryStaple: Bool
    var owned: Bool
    var sources: [IngredientSource]
    var needsReview: Bool
}
