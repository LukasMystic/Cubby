//
//  DialogueViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import Combine
import Foundation

// What the dialogue screen renders at any given moment
enum DialogueBeat {
    case narrative(text: String)
    case speech(speaker: String, text: String)
    case choice(options: [DecisionRoute])
    case ending(emotion: String)
}

final class DialogueViewModel: ObservableObject {

    @Published private(set) var currentBeat: DialogueBeat = .narrative(text: "")
    @Published private(set) var isEnded = false
    @Published private(set) var playerName = "Joey"

    private var router: StoryRouter?
    private var currentScene: StoryScene?
    private var nodeIndex = 0

    init() {
        loadStory()
    }

    // MARK: - Story Loading

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

    private func loadJSON<T: Codable>(_ fileName: String) -> T? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(T.self, from: data)
        else {
            print("[Story] Could not load \(fileName).json")
            return nil
        }
        return result
    }

    func restart() {
        isEnded = false
        nodeIndex = 0
        loadStory()
    }

    // MARK: - Navigation

    // Advance to the next story beat (tapping the dialogue panel or the next arrow)
    func advance() {
        // If we're showing choices, wait for the player to pick — tapping does nothing
        guard case .choice = currentBeat else {
            showNextBeat()
            return
        }
    }

    // Player picked a decision route — load the branch file and continue
    func choose(_ route: DecisionRoute) {
        let fileName = route.targetFile.replacingOccurrences(of: ".json", with: "")
        loadScene(named: fileName)
        showNextBeat()
    }

    // Walk through the sequence until we land on something to display
    private func showNextBeat() {
        guard let scene = currentScene else { return }

        while nodeIndex < scene.sequence.count {
            let node = scene.sequence[nodeIndex]
            nodeIndex += 1

            if let beat = beat(for: node) {
                currentBeat = beat
                return
            }
            // nil means silently skip (e.g. player_identity metadata nodes)
        }
    }

    // Map a story node to what the UI should show (nil = skip)
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
