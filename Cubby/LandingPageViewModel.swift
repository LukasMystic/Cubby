//
//  LandingPageViewModel.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 03/07/26.
//

//on tap, navigate to Selection Page

// MARK: - LandingPageViewModel
import Combine

final class LandingPageViewModel: ObservableObject {
    @Published var goToCharacterSelection = false

    func onPlayButtonTapped() {
        goToCharacterSelection = true
    }
}
