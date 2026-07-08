//
//  UserProgress.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 07/07/26.
//

import Foundation

struct UserProgress: Codable {
    // decisionId (node_id of the decision_point) -> chosen option key (e.g. "1A")
    var decisions: [String: String] = [:]
}
