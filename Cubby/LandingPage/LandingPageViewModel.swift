//
//  LandingPageViewModel.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 03/07/26.
//

//on tap, navigate to Selection Page

import Observation

@Observable final class LandingPageViewModel{
    var goToCharacterSelection = false

    func onPlayButtonTapped() {
        goToCharacterSelection = true
    }
}
