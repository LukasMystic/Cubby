//
//  File.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

import Observation

@Observable class CharacterSelectionViewModel {
    var selectedCharacter: String?
    
    func selectCharacter(_ character: String) {
        selectedCharacter = character
    }
}
