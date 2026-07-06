//
//  GameViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//
// YES I USE AI FOR MOST OF THIS

import Combine
import SpriteKit
import SwiftUIJoystick
import TipKit

// Both the ViewModel and GameScene need to know if the character is idle or walking
enum CharacterAnim: Equatable { case idle, walking }

final class GameViewModel: ObservableObject {

    // Scene
    var scene: SKScene { gameScene }
    private let gameScene: GameScene

    // Joystick
    let joystickSize: CGFloat = 150
    let joystickMonitor: JoystickMonitor

    // Character state — NOT @Published because these change every frame at 60fps
    var characterPosition: CGPoint = .zero
    var isFacingRight: Bool = true
    var characterAnim: CharacterAnim = .idle

    // Set by GameScene once it knows the actual screen and sprite size
    var sceneSize: CGSize = .zero
    var charHalfW: CGFloat = 40
    var charHalfH: CGFloat = 60

    // NPC position in scene coordinates — set by GameScene after the NPC is placed
    var npcPosition: CGPoint = .zero

    // Movement
    private let moveSpeed: CGFloat = 220
    private let deadzone: CGFloat = 10

    // Triggers the DialogueView to appear
    @Published var showDialogue = false

    init() {
        joystickMonitor = JoystickMonitor()
        let s = GameScene()
        s.scaleMode = .resizeFill
        gameScene = s
        s.viewModel = self
    }

    // MARK: - Game Loop

    // Runs every frame — reads joystick input and moves the character
    func tick(deltaTime dt: CGFloat) {
        let dx = joystickMonitor.xyPoint.x
        let dy = joystickMonitor.xyPoint.y

        // If the player is barely touching the joystick, just stand still
        guard sqrt(dx * dx + dy * dy) > deadzone else {
            characterAnim = .idle
            return
        }

        // Scale the raw joystick output to a –1 … 1 range
        let normX = dx / joystickSize
        let normY = dy / joystickSize

        // Move and clamp to the scene edges
        let newX = min(max(characterPosition.x + normX * moveSpeed * dt, charHalfW), sceneSize.width - charHalfW)
        let newY = min(max(characterPosition.y - normY * moveSpeed * dt, charHalfH), sceneSize.height - charHalfH)
        characterPosition = CGPoint(x: newX, y: newY)

        // Face the direction the player is pushing
        if normX < -0.1 { isFacingRight = false }
        else if normX > 0.1 { isFacingRight = true }

        characterAnim = .walking
    }

    // MARK: - Interact

    // Opens the dialogue page if the player is close enough to the NPC
    func interact() {
        let dx = characterPosition.x - npcPosition.x
        let dy = characterPosition.y - npcPosition.y
        guard sqrt(dx * dx + dy * dy) < 180 else {
            print("[Interact] No NPC in range — move closer.")
            return
        }
        InteractTip().invalidate(reason: .actionPerformed)
        Task { await InteractTip.useInteract.donate() }
        showDialogue = true
    }
}
