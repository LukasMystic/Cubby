//
//  DialogueAudioManager.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import AVFoundation
import UIKit

final class DialogueAudioManager {

    private var players: [String: AVAudioPlayer] = [:]
    private var typewriterCount = 0

    init() {
        let names = [
            "sfx_dialogue_box_appear_1",
            "sfx_choice_panel_appear_1",
            "sfx_choice_button_tap_1",
            "sfx_text_type_soft_1",
            "sfx_ui_next_soft_1",
            "sfx_ui_back_soft_1",
            "sfx_emotion_happy_soft_1",
            "sfx_emotion_relieved_breath_1",
            "sfx_emotion_uncomfortable_soft_1",
            "sfx_emotion_annoyed_soft_1",
            "sfx_emotion_upset_soft_1",
            "sfx_emotion_cry_soft_1"
        ]
        for name in names { players[name] = load(name) }
    }

    private func load(_ name: String) -> AVAudioPlayer? {
        guard let asset = NSDataAsset(name: name),
              let player = try? AVAudioPlayer(data: asset.data) else {
            print("audio: couldn't load \(name)")
            return nil
        }
        player.prepareToPlay()
        return player
    }

    private func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    func onDialogueBoxAppear() { play("sfx_dialogue_box_appear_1") }
    func onChoicePanelAppear() { play("sfx_choice_panel_appear_1") }
    func onChoiceTap()         { play("sfx_choice_button_tap_1") }
    func onNext()              { play("sfx_ui_next_soft_1") }
    func onBack()              { play("sfx_ui_back_soft_1") }

    func onTypewriterChar() {
        typewriterCount += 1
        if typewriterCount % 3 == 0 { play("sfx_text_type_soft_1") }
    }

    func resetTypewriter() { typewriterCount = 0 }

    func onEmotionChange(_ key: String) {
        switch key.lowercased() {
        case "happy":                             play("sfx_emotion_happy_soft_1")
        case "relieved":                          play("sfx_emotion_relieved_breath_1")
        case "uncomfortable", "silentdiscomfort": play("sfx_emotion_uncomfortable_soft_1")
        case "annoyed":                           play("sfx_emotion_annoyed_soft_1")
        case "angry":                             play("sfx_emotion_upset_soft_1")
        case "crying", "sobbing":                 play("sfx_emotion_cry_soft_1")
        default: break
        }
    }
}
