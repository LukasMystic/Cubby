import SwiftUI
import TipKit
import AVFoundation

@main
struct CubbyApp: App {
    @State private var router = AppRouter()

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

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
