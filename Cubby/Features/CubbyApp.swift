import SwiftUI
import TipKit

@main
struct CubbyApp: App {
    @State private var router = AppRouter()

    init() {
        #if DEBUG
        try? Tips.resetDatastore()
        #endif
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
        }
    }
}
