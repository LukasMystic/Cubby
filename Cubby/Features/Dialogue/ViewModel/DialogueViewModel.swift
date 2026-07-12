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
    private(set) var miaExpressionKey: String = ""
    private(set) var joeyExpressionKey: String = ""
    private(set) var isEnded = false
    private(set) var beatCounter: Int = 0

    var miaAssetName: String { miaAsset(for: miaExpressionKey) }
    var joeyAssetName: String { joeyAsset(for: joeyExpressionKey) }

    private func miaAsset(for key: String) -> String {
        switch key.lowercased() {
        case "neutral":return "EX_Mia_001_Neutral"
        case "relieved": return "EX_Mia_002_Relieved"
        case "happy":return "EX_Mia_003_Happy"
        case "uncomfortable": return "EX_Mia_004_Uncomfortable"
        case "silentdiscomfort": return "EX_Mia_005_SilentDiscomfort"
        case "annoyed": return "EX_Mia_006_Annoyed"
        case "angry": return "EX_Mia_007_Angry"
        case "crying":return "EX_Mia_008_Crying"
        case "sobbing":return "EX_Mia_009_Sobbing"
        default:return "EX_Mia_001_Neutral"
        }
    }

    private func joeyAsset(for key: String) -> String {
        switch key.lowercased() {
        case "neutral": return "EX_Joey_001_Neutral"
        case "talk", "neutraltalk":return "EX_Joey_002_Talk"
        case "excited": return "EX_Joey_003_Excited"
        case "unaware":return "EX_Joey_004_Unaware"
        case "happy": return "EX_Joey_005_Happy"
        case "happyeyesclosed":return "EX_Joey_006_HappyEyesClosed"
        default: return "EX_Joey_001_Neutral"
        }
    }

    private var router: StoryRouter?
    private var currentScene: StoryScene?
    private var nodeIndex = 0
    private var currentDecisionId: String?

    init() {
        loadStory()
    }

    // load story
    private func loadStory() {
        router = loadJSON("main")
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
    func advance() {
        if case .choice = currentBeat { return } // choices are handled by choose(_:), not advance
        showNextBeat()
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

            updateExpressions(from: node)

            if let beat = beat(for: node) {
                currentBeat = beat
                beatCounter += 1
                return
            }
        }
    }

    private func updateExpressions(from node: StoryNode) {
        guard let exprs = node.characterExpressions else { return }
        if let mia = exprs.mia { miaExpressionKey = mia.expressionKey }
        if let joey = exprs.joey { joeyExpressionKey = joey.expressionKey }
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
        print("progress saved at: \(progressFileURL.path)")
    }

    func saveDecisionScreenshot(_ image: UIImage, targetFile: String) {
        guard let data = image.pngData() else { return }
        let filename = targetFile.replacingOccurrences(of: ".json", with: "") + ".png"
        let url = progressFileURL.deletingLastPathComponent().appendingPathComponent(filename)
        try? data.write(to: url, options: .atomic)
    }
    
    private func resetProgress() {
        let empty = UserProgress()
        if let data = try? JSONEncoder().encode(empty) {
            try? data.write(to: progressFileURL, options: .atomic)
        }
        clearOldScreenshots()
    }

    private func clearOldScreenshots() {
        let docsDir = progressFileURL.deletingLastPathComponent()
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: docsDir, includingPropertiesForKeys: nil
        ) else { return }

        for url in urls where url.pathExtension == "png" {
            try? FileManager.default.removeItem(at: url)
        }
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
