import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        ContentUnavailableView(
            "Shopping List",
            systemImage: "cart",
            description: Text("Unchecked ingredients will form the shopping list here.")
        )
        .navigationTitle("Shopping List")
    }
}

#Preview {
    NavigationStack { ShoppingListView() }
}
