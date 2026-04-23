import SwiftUI

struct IngredientChecklistView: View {
    var body: some View {
        ContentUnavailableView(
            "Checklist",
            systemImage: "checklist",
            description: Text("Merged ingredients grouped by category will live here.")
        )
        .navigationTitle("Checklist")
    }
}

#Preview {
    NavigationStack { IngredientChecklistView() }
}
