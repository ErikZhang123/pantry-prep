import SwiftUI

struct HomeView: View {
    var body: some View {
        ContentUnavailableView(
            "Home",
            systemImage: "fork.knife",
            description: Text("Recipe input, servings, and generate button will live here.")
        )
        .navigationTitle("PantryPrep")
    }
}

#Preview {
    NavigationStack { HomeView() }
}
