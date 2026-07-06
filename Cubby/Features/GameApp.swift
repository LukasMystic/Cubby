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
        try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
