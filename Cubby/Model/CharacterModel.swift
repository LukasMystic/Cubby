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
        "Primary-Joey-CharacterSelection-Image": Character(
            id: "Primary-Joey-CharacterSelection-Image",
            name: "Joey",
            bioText: "Aku sangat suka kenal orang baru dan mencoba hal-hal baru juga. Aku suka berpelukan, saling tos, dan senyum sapa.",
            imageName: "Primary-Joey-CharacterSelection-Image"
        ),
        "Primary-Mia-CharacterSelection-Image": Character(
            id: "Primary-Mia-CharacterSelection-Image",
            name: "Mia",
            bioText: "Aku anak yang pemalu, aku tidak suka berpelukan, cukup melambai saja sudah membuat aku senang!",
            imageName: "Primary-Mia-CharacterSelection-Image"
        )
    ]
}
