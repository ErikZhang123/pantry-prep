import SwiftUI

struct SettingsView: View {
    var body: some View {
        ContentUnavailableView(
            "Settings",
            systemImage: "gear",
            description: Text("Default servings, pantry staples, and data controls will live here.")
        )
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
