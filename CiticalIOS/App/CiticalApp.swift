import SwiftUI

@main
struct CiticalApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppStore())
        }
    }
}

