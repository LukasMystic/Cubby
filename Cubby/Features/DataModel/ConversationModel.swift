//
//  ConversationModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import Foundation

struct Conversation: Codable, Identifiable {
    let id: String
    let npcName: String
    let portrait: String
    let lines: [DialogueLine]
}

struct DialogueLine: Codable, Identifiable {
    let id: String
    let speaker: String
    let text: String
}
