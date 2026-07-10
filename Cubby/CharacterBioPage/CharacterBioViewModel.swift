//
//  CharacterBioViewModel.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

import Observation

@Observable class CharacterBioViewModel {
    let character: Character
    var navigateToGame = false
    
    init(selectedCharacter: String) {
        self.character = Character.all[selectedCharacter]!
    }
    
    func playTapped() {
        navigateToGame = true
    }
}
