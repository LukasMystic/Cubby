//
//  StorybookModel.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 09/07/26.
//

// Models/StorybookPage.swift

import Foundation

// MARK: - BranchFile
// Wraps a full branch JSON (1.json, 1A.json, etc). We only care about
// storybook_page — Codable automatically ignores the other fields
// (sequence, selected_option, connects_from, etc.) since we don't
// declare properties for them.

struct BranchFile: Codable {
    let fileName: String
    let storybookPage: StorybookPage?

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
        case storybookPage = "storybook_page"
    }
}

// MARK: - StorybookPage

struct StorybookPage: Codable, Identifiable, Hashable {
    let id: String
    let playerChose: String
    let sourceFile: String
    let pageType: PageType
    let title: String
    let sections: [StorybookSection]

    enum CodingKeys: String, CodingKey {
        case id = "page_id"
        case playerChose = "player_chose"
        case sourceFile = "source_file"
        case pageType = "page_type"
        case title, sections
    }
}

// MARK: - PageType

enum PageType: String, Codable {
    case choiceRecap = "choice_recap"
    case endingRecap = "ending_recap"
}

// MARK: - StorybookSection

struct StorybookSection: Codable, Hashable {
    let heading: String
    let body: String?
    let questions: [String]?
}
