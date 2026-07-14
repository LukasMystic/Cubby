//
//  AppRouter.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 12/07/26.
//

import Foundation

enum AppScreen: Equatable {
    case landing
    case characterSelection
    case characterBio(character: String)
    case game
    case dialogue
    case storybook
    case closing
}

@Observable
class AppRouter {
    var current: AppScreen = .landing
}
