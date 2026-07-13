import Foundation

struct Character {
    let id: String
    let name: String
    let bioText: String
    let polaroidName: String
    let fullBodyName: String
}

extension Character {
    static let all: [String: Character] = [
        "joey": Character(
            id: "joey",
            name: "Joey",
            bioText: "I love to have new friends and trying new things. I love hugs, high-fives, and big smiles!",
            polaroidName: "Joey_polaroid",
            fullBodyName: "joey 3"
        ),
        "mia": Character(
            id: "mia",
            name: "Mia",
            bioText: "I'm a little shy, I don't like hugs, but a wave or a smile makes me happy!",
            polaroidName: "Mia_polaroid",
            fullBodyName: "mia_1 2"
        )
    ]
}
