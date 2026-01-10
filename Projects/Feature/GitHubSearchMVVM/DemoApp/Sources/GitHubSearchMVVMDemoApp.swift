import SwiftUI

@main
struct GitHubSearchMVVMDemoApp: App {
    init() {
        // DI Container 설정
        GitHubSearchDIContainer.shared.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

