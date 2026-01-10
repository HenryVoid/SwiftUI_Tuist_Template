import SwiftUI
import ComposableArchitecture

@main
struct GitHubSearchTCADemoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(store: Store(initialState: HomeFeature.State()) {
                HomeFeature()
            })
        }
    }
}

