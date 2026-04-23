import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "fork.knife") }

            NavigationStack { IngredientChecklistView() }
                .tabItem { Label("Checklist", systemImage: "checklist") }

            NavigationStack { ShoppingListView() }
                .tabItem { Label("Shopping", systemImage: "cart") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    RootView()
}
