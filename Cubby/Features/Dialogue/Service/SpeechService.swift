//
//  CubbyApp.swift
//  Cubby
//
//  Created by Sayyidah Fatimah Azzahra on 10/07/26.
//

import AVFoundation

final class SpeechService {
    static let shared = SpeechService()

    private var player: AVAudioPlayer?

    func play(nodeId: String) {
        stop()
            guard let url = Bundle.main.url(forResource: nodeId, withExtension: "mp3") else {
            print("[Speech] Missing audio: \(nodeId).mp3")
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }

    func stop() { player?.stop() }
}
