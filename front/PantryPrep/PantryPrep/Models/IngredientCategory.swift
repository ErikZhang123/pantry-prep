import Foundation

enum IngredientCategory: String, Codable, CaseIterable, Hashable {
    case vegetable
    case protein
    case dairy
    case condiment
    case grain
    case spice
    case pantry
    case seafood
    case fruit
    case other

    var displayName: String {
        switch self {
        case .vegetable: return "Vegetable"
        case .protein: return "Protein"
        case .dairy: return "Dairy"
        case .condiment: return "Condiment"
        case .grain: return "Grain"
        case .spice: return "Spice"
        case .pantry: return "Pantry"
        case .seafood: return "Seafood"
        case .fruit: return "Fruit"
        case .other: return "Other"
        }
    }
}
