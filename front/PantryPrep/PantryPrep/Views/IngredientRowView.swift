import SwiftUI

struct IngredientRowView: View {
    let ingredient: MergedIngredient
    let onToggleOwned: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleOwned) {
                Image(systemName: ingredient.owned ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(ingredient.owned ? Color.green : Color.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(ingredient.owned ? "Mark as not owned" : "Mark as owned")

            Button(action: onEdit) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ingredient.displayName)
                            .font(.body)
                            .strikethrough(ingredient.owned)
                            .foregroundStyle(ingredient.owned ? Color.secondary : Color.primary)
                        secondaryLine
                    }
                    Spacer()
                    badges
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .opacity(ingredient.owned ? 0.6 : 1.0)
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
        IngredientRowView(
            ingredient: MergedIngredient(
                id: UUID(), displayName: "Eggs", canonicalName: "egg",
                totalQuantity: 6, unit: "pcs", category: .protein,
                optional: false, pantryStaple: false, owned: false,
                sources: [], needsReview: false
            ),
            onToggleOwned: {},
            onEdit: {}
        )
        IngredientRowView(
            ingredient: MergedIngredient(
                id: UUID(), displayName: "Green Onion", canonicalName: "green onion",
                totalQuantity: nil, unit: nil, category: .vegetable,
                optional: false, pantryStaple: false, owned: false,
                sources: [], needsReview: true
            ),
            onToggleOwned: {},
            onEdit: {}
        )
        IngredientRowView(
            ingredient: MergedIngredient(
                id: UUID(), displayName: "Salt", canonicalName: "salt",
                totalQuantity: nil, unit: "pinch", category: .spice,
                optional: false, pantryStaple: true, owned: true,
                sources: [], needsReview: false
            ),
            onToggleOwned: {},
            onEdit: {}
        )
    }
}
