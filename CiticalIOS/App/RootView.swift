import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "list.bullet.rectangle") }

            MapScreenView()
                .tabItem { Label("Map", systemImage: "map") }

            AboutView()
                .tabItem { Label("About", systemImage: "sparkles") }
        }
        .tint(Theme.orange)
        .background(Theme.background)
        .onAppear { store.refresh() }
    }
}

