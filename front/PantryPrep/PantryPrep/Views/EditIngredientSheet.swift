import SwiftUI

struct EditIngredientSheet: View {
    let original: MergedIngredient
    let onSave: (MergedIngredient) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String
    @State private var quantityText: String
    @State private var unit: String
    @State private var category: IngredientCategory
    @State private var optional: Bool
    @State private var pantryStaple: Bool

    init(original: MergedIngredient, onSave: @escaping (MergedIngredient) -> Void) {
        self.original = original
        self.onSave = onSave
        _displayName = State(initialValue: original.displayName)
        _quantityText = State(initialValue: original.totalQuantity.map { Self.format($0) } ?? "")
        _unit = State(initialValue: original.unit ?? "")
        _category = State(initialValue: original.category)
        _optional = State(initialValue: original.optional)
        _pantryStaple = State(initialValue: original.pantryStaple)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient") {
                    TextField("Name", text: $displayName)
                }

                Section("Quantity") {
                    HStack {
                        TextField("Amount", text: $quantityText)
                            .keyboardType(.decimalPad)
                        TextField("Unit", text: $unit)
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Toggle("Optional", isOn: $optional)
                    Toggle("Pantry staple", isOn: $pantryStaple)
                }

                if original.needsReview {
                    Section {
                        Label("This ingredient had a unit conflict. Saving your edit will clear the review flag.", systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        var updated = original
        updated.displayName = displayName.trimmingCharacters(in: .whitespaces)
        updated.totalQuantity = Double(quantityText.replacingOccurrences(of: ",", with: "."))
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)
        updated.unit = trimmedUnit.isEmpty ? nil : trimmedUnit
        updated.category = category
        updated.optional = optional
        updated.pantryStaple = pantryStaple
        updated.needsReview = false
        onSave(updated)
    }

    private static func format(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}

#Preview {
    EditIngredientSheet(
        original: MergedIngredient(
            id: UUID(), displayName: "Green Onion", canonicalName: "green onion",
            totalQuantity: nil, unit: nil, category: .vegetable,
            optional: false, pantryStaple: false, owned: false,
            sources: [], needsReview: true
        )
    ) { _ in }
}
