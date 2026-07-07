//
//  ConversationModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import Foundation

// Every possible node type that can appear in a scene's sequence
enum StoryNodeType: String, Codable {
    case dialogue
    case situationNarrator = "situation_narrator"
    case contextEmotion    = "context_emotion"
    case decisionPoint     = "decision_point"
    case playerIdentity    = "player_identity"
    case backgroundSetting = "background_setting"
    case ending
}

// Dialogue line nested inside a context_emotion node
struct InlineDialogue: Codable {
    let speaker: String
    let text: String
}

// One beat in the story
struct StoryNode: Codable {
    let nodeId: String
    let type: StoryNodeType

    // present on dialogue / context_emotion nodes
    let speaker: String?
    let text: String?

    // present on decision_point nodes
    let decisionPrompt: String?

    // present on context_emotion nodes
    let emotion: String?
    let dialogue: InlineDialogue?

    // present on ending nodes
    let finalEmotion: String?

    enum CodingKeys: String, CodingKey {
        case nodeId        = "node_id"
        case type, speaker, text, emotion, dialogue
        case decisionPrompt = "decision_prompt"
        case finalEmotion   = "final_emotion"
    }
}

// Decoded from any scene file: opening.json, 1.json, 1A.json, etc.
struct StoryScene: Codable {
    let sequence: [StoryNode]
}

// One option the player can pick at a decision point
struct DecisionRoute: Codable, Identifiable {
    var id: String { option }
    let option: String
    let choiceText: String
    let targetFile: String

    enum CodingKeys: String, CodingKey {
        case option
        case choiceText  = "choice_text"
        case targetFile  = "target_file"
    }
}

// One decision block inside main.json
struct StoryDecision: Codable {
    let decisionId: String
    let routes: [DecisionRoute]

    enum CodingKeys: String, CodingKey {
        case decisionId = "decision_id"
        case routes
    }
}

// main.json — router/index for the whole story
struct StoryRouter: Codable {
    let entryPoint: EntryPoint
    let decisions: [StoryDecision]

    struct EntryPoint: Codable {
        let file: String
        enum CodingKeys: String, CodingKey { case file }
    }

    enum CodingKeys: String, CodingKey {
        case entryPoint = "entry_point"
        case decisions
    }
}
