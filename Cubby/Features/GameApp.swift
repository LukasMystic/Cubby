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
        // Configure TipKit once at launch.
        // .immediate means tips are not throttled — they appear as soon as rules are met,
        // making the tutorial flow sequentially within the first session.
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
