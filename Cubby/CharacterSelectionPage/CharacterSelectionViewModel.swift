//
//  File.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

import Combine

class CharacterSelectionViewModel: ObservableObject {
    @Published var selectedCharacter: String?
    
    func selectCharacter(_ character: String) {
        selectedCharacter = character
    }
}
