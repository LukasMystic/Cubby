//
//  DialogueViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import Foundation
import UIKit
import Observation

// dialogue screen renders
enum DialogueBeat {
    case narrative(text: String)
    case speech(speaker: String, text: String)
    case choice(options: [DecisionRoute])
    case ending(emotion: String)
}

@Observable
final class DialogueViewModel {

    private(set) var currentBeat: DialogueBeat = .narrative(text: "")
    private(set) var isEnded = false
    private(set) var playerName = "Joey"

    private var router: StoryRouter?
    private var currentScene: StoryScene?
    private var nodeIndex = 0
    private var currentDecisionId: String?

    init() {
        print("📁 save folder:", progressFileURL.deletingLastPathComponent().path)
        loadStory()
    }

    // load story
    private func loadStory() {
        router = loadJSON("main")
        if let name = router?.characterNames?.player { playerName = name }
        let entryFile = router?.entryPoint.file ?? "opening.json"
        let sceneName = entryFile.replacingOccurrences(of: ".json", with: "")
        loadScene(named: sceneName)
        showNextBeat()
    }

    private func loadScene(named fileName: String) {
        currentScene = loadJSON(fileName)
        nodeIndex = 0
    }

    // generic json loader
    private func loadJSON<T: Codable>(_ fileName: String) -> T? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(T.self, from: data)
        else {
            print("couldn't load \(fileName).json")
            return nil
        }
        return result
    }

    // Navigation
    func restart() {
        isEnded = false
        nodeIndex = 0
        loadStory()
    }

    // MARK: - Navigation

    func advance() {
        // if it's a choice panel, do nothing 
        guard case .choice = currentBeat else {
            showNextBeat()
            return
        }
    }

    func choose(_ route: DecisionRoute) {
        if let decisionId = currentDecisionId {
            saveProgress(decisionId: decisionId, chosenOption: route.option)
            currentDecisionId = nil
        }
        let fileName = route.targetFile.replacingOccurrences(of: ".json", with: "")
        loadScene(named: fileName)
        showNextBeat()
    }

    private func showNextBeat() {
        guard let scene = currentScene else { return }

        while nodeIndex < scene.sequence.count {
            let node = scene.sequence[nodeIndex]
            nodeIndex += 1

            if let beat = beat(for: node) {
                currentBeat = beat
                return
            }
            // some nodes (like player_identity) are skipped
        }
    }

    // save or load progress

    private var progressFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("userProgress.json")
    }

    private func loadProgress() -> UserProgress {
        guard let data = try? Data(contentsOf: progressFileURL),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data)
        else { return UserProgress() }
        return progress
    }

    private func saveProgress(decisionId: String, chosenOption: String) {
        var progress = loadProgress()
        progress.decisions[decisionId] = chosenOption
        guard let data = try? JSONEncoder().encode(progress) else { return }
        try? data.write(to: progressFileURL, options: .atomic)
    }

    // called from the view right before choose() while the decision screen is still visible
    // targetFile is route.targetFile e.g. "1A.json" → saved as "1A.png"
    func saveDecisionScreenshot(_ image: UIImage, targetFile: String) {
        guard let data = image.pngData() else { return }
        let filename = targetFile.replacingOccurrences(of: ".json", with: "") + ".png"
        let url = progressFileURL.deletingLastPathComponent().appendingPathComponent(filename)
        try? data.write(to: url, options: .atomic)
    }

    private func beat(for node: StoryNode) -> DialogueBeat? {
        switch node.type {
        case .playerIdentity:
            return nil

        case .backgroundSetting, .situationNarrator:
            SpeechService.shared.play(nodeId: node.nodeId)
            return .narrative(text: node.text ?? "")

        case .dialogue:
            SpeechService.shared.play(nodeId: node.nodeId)
            return .speech(speaker: node.speaker ?? "", text: node.text ?? "")

        case .contextEmotion:
            SpeechService.shared.play(nodeId: node.nodeId)
            if let inline = node.dialogue {
                return .speech(speaker: inline.speaker, text: inline.text)
            }
            return .narrative(text: node.text ?? "")

        case .decisionPoint:
            currentDecisionId = node.nodeId
            SpeechService.shared.stop()
            let choices = router?.decisions
                .first(where: { $0.decisionId == node.nodeId })?
                .routes ?? []
            return .choice(options: choices)

        case .ending:
            SpeechService.shared.stop()
            isEnded = true
            return .ending(emotion: node.finalEmotion ?? "")
        }
    }
}
