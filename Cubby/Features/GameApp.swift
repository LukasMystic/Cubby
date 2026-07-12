//
//  CubbyApp.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import TipKit
import AVFoundation

@main
struct GameApp: App {

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        // In DEBUG builds, wipe the TipKit datastore on every launch so tips
        // always appear during development and testing.
        #if DEBUG
        try? Tips.resetDatastore()
        #endif

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
            CutsceneView()
        }
    }
}
