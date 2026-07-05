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
    private var didDonateJoystickUse = false

        // Scene
        var scene: SKScene { gameScene }
    private let gameScene: GameScene

        // Joystick
        let joystickSize: CGFloat = 150
        let joystickMonitor: JoystickMonitor

        // Character
        var characterPosition: CGPoint = .zero
        var isFacingRight: Bool = true
        var characterAnim: CharacterAnim = .idle

        // fiils the scenes in once it knows the actual screen and sprite size
        var sceneSize: CGSize = .zero
        var charHalfW: CGFloat = 40
        var charHalfH: CGFloat = 60

        // Movement
        private let moveSpeed: CGFloat = 220
        private let deadzone: CGFloat = 10  // delta error

        // Dialogue -> for later :b
        @Published private(set) var isShowingDialogue = false
        @Published private(set) var activeConversation: Conversation?
        @Published private(set) var currentLineIndex = 0

        var currentLine: DialogueLine? {
            guard let conv = activeConversation,
                  currentLineIndex < conv.lines.count else { return nil }
            return conv.lines[currentLineIndex]
        }

    // karena OOP perlu init :b

    init() {
        joystickMonitor = JoystickMonitor()
            let s = GameScene()
            s.scaleMode = .resizeFill
            gameScene = s
            s.viewModel = self
    }

    // Game loop concept

    // runs every frame -> It reads where the joystick is and decides where the character should move and what animation to play
    func tick(deltaTime dt: CGFloat) {
        let dx = joystickMonitor.xyPoint.x
            let dy = joystickMonitor.xyPoint.y

            // If the player is barely touching the joystick, just stand still
            guard sqrt(dx * dx + dy * dy) > deadzone else {
                characterAnim = .idle
                    return
            }

        // Scale the joystick input down to a -1 to 1 range
        let normX = dx / joystickSize
            let normY = dy / joystickSize

            // Move the character and make sure it doesn't walk off the edges
            let newX = min(max(characterPosition.x + normX * moveSpeed * dt, charHalfW), sceneSize.width - charHalfW)
            let newY = min(max(characterPosition.y - normY * moveSpeed * dt, charHalfH), sceneSize.height - charHalfH)
            characterPosition = CGPoint(x: newX, y: newY)

            // Face left or right depending on which way the player is pushing
            if normX < -0.1 { isFacingRight = false }
            else if normX > 0.1 { isFacingRight = true }

        characterAnim = .walking

        if !didDonateJoystickUse {
            didDonateJoystickUse = true
                JoystickTip().invalidate(reason: .actionPerformed)
                Task { await InteractTip.useJoystick.donate()}
        }
    }

    // Interact -> for later :b

    func interact() {
        print("[Interact] Button pressed — player position: \(characterPosition)")
            // TODO: check if the player is close enough to an NPC, then start a conversation
    }

    // MARK: - Dialogue

    func startConversation(_ conversation: Conversation) {
        activeConversation = conversation
            currentLineIndex = 0
            isShowingDialogue = true
    }

    // Move to the next line, or close the dialogue if we've reached the end
    func advanceDialogue() {
        guard let conv = activeConversation else { return }
        if currentLineIndex + 1 < conv.lines.count {
            currentLineIndex += 1
        } else {
            dismissDialogue()
        }
    }

    func dismissDialogue() {
        isShowingDialogue = false
            activeConversation = nil
            currentLineIndex = 0
    }

    // Data loading -> bakal buat file buat later

    func loadConversation(named fileName: String) -> Conversation? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let conversation = try? JSONDecoder().decode(Conversation.self, from: data)
                    else { return nil }
                    return conversation
    }
}
