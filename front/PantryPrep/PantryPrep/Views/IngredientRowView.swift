import SwiftUI

struct IngredientRowView: View {
    let ingredient: MergedIngredient

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.displayName)
                    .font(.body)
                secondaryLine
            }
            Spacer()
            badges
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var secondaryLine: some View {
        if ingredient.needsReview {
            Text("Unit conflict — tap to review")
                .font(.caption)
                .foregroundStyle(.orange)
        } else if let qty = ingredient.totalQuantity, let unit = ingredient.unit {
            Text("\(Self.formatQuantity(qty)) \(unit)")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if let unit = ingredient.unit {
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var badges: some View {
        HStack(spacing: 6) {
            if ingredient.pantryStaple {
                Image(systemName: "cabinet")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                    .accessibilityLabel("Pantry staple")
            }
            if ingredient.optional {
                Text("optional")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
            if ingredient.needsReview {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Needs review")
            }
        }
    }

    private static func formatQuantity(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}

#Preview {
    List {
        IngredientRowView(ingredient: MergedIngredient(
            id: UUID(), displayName: "Eggs", canonicalName: "egg",
            totalQuantity: 6, unit: "pcs", category: .protein,
            optional: false, pantryStaple: false, owned: false,
            sources: [], needsReview: false
        ))
        IngredientRowView(ingredient: MergedIngredient(
            id: UUID(), displayName: "Green Onion", canonicalName: "green onion",
            totalQuantity: nil, unit: nil, category: .vegetable,
            optional: false, pantryStaple: false, owned: false,
            sources: [], needsReview: true
        ))
        IngredientRowView(ingredient: MergedIngredient(
            id: UUID(), displayName: "Sesame Oil", canonicalName: "sesame oil",
            totalQuantity: 1, unit: "tsp", category: .condiment,
            optional: true, pantryStaple: false, owned: false,
            sources: [], needsReview: false
        ))
    }
}
