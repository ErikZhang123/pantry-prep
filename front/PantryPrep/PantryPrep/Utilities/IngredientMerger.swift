import Foundation

enum IngredientMerger {
    static func merge(_ dtos: [IngredientDTO]) -> [MergedIngredient] {
        let groups = Dictionary(grouping: dtos) { IngredientNormalizer.normalize($0.canonicalName) }

        let merged = groups.map { (canonical, items) -> MergedIngredient in
            let units = Set(items.compactMap { $0.unit })
            let sources = items.map {
                IngredientSource(recipeName: $0.recipeName, quantity: $0.quantity, unit: $0.unit)
            }
            let needsReview = units.count > 1

            let totalQuantity: Double?
            let unit: String?
            if needsReview {
                totalQuantity = nil
                unit = nil
            } else {
                let quantities = items.compactMap { $0.quantity }
                totalQuantity = quantities.isEmpty ? nil : quantities.reduce(0, +)
                unit = items.compactMap { $0.unit }.first
            }

            let first = items.first!
            return MergedIngredient(
                id: UUID(),
                displayName: first.displayName,
                canonicalName: canonical,
                totalQuantity: totalQuantity,
                unit: unit,
                category: first.category,
                optional: items.allSatisfy { $0.optional },
                pantryStaple: items.contains { $0.pantryStaple },
                owned: false,
                sources: sources,
                needsReview: needsReview
            )
        }

        return merged.sorted { lhs, rhs in
            if lhs.category == rhs.category {
                return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
            }
            return lhs.category.rawValue < rhs.category.rawValue
        }
    }
}
