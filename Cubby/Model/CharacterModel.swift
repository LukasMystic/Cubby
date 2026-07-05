//
//  CharacterBioModel.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

struct Character {
    let id: String
    let name: String
    let bioText: String
    let imageName: String
}

extension Character {
    static let all: [String: Character] = [
        "Primary-Joey-CharacterSelectionPage-Image": Character(
            id: "Primary-Joey-CharacterSelectionPage-Image",
            name: "Joey",
            bioText: "Joey's bio",
            imageName: "Primary-Joey-CharacterSelectionPage-Image"
        ),
        "Primary-Mia-CharacterSelectionPage-Image": Character(
            id: "Primary-Mia-CharacterSelectionPage-Image",
            name: "Mia",
            bioText: "Mia's bio",
            imageName: "Primary-Mia-CharacterSelectionPage-Image"
        )
    ]
}
