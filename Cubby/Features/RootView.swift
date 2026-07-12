//
//  RootView.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 12/07/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        switch router.current {
        case .landing:
            LandingPageView()
        case .characterSelection:
            CharacterSelectionView()
        case .characterBio(let character):
            CharacterBioView(selectedCharacter: character)
        case .game, .dialogue, .storybook, .closing:
            CutsceneView() 
        }
    }
}
