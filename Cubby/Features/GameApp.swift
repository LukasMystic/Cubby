//
//  CubbyApp.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import TipKit

@main
struct GameApp: App {
    init() {
        #if DEBUG
        // must run before configure, or tips stay marked as already-shown
        try? Tips.resetDatastore()
        #endif

        try? Tips.configure([.displayFrequency(.immediate)])
    }

    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
