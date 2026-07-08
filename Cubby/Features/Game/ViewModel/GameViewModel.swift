//
//  GameViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//
// YES I USE AI FOR MOST OF THIS

import SpriteKit
import SwiftUIJoystick
import Observation

// idle or walking - GameScene needs this too
enum CharacterAnim: Equatable { case idle, walking }

@Observable
final class GameViewModel {

    var scene: SKScene { gameScene }
    private let gameScene: GameScene

    let joystickSize: CGFloat = 150
    let joystickMonitor: JoystickMonitor

    var characterPosition: CGPoint = .zero
    var isFacingRight: Bool = true
    var characterAnim: CharacterAnim = .idle

    // these get set by GameScene once the scene loads
    var sceneSize: CGSize = .zero
    var charHalfW: CGFloat = 40
    var charHalfH: CGFloat = 60

    var npcPosition: CGPoint = .zero
    var isNPCInRange: Bool = false

    private let moveSpeed: CGFloat = 220
    private let deadzone: CGFloat = 10 // ignore tiny joystick movements

    var showDialogue = false

    var isPaused = false {
        didSet { gameScene.isPaused = isPaused }
    }

    init() {
        joystickMonitor = JoystickMonitor()
        let s = GameScene()
        s.scaleMode = .resizeFill
        gameScene = s
        s.viewModel = self
    }

    // called every frame from GameScene
    func tick(deltaTime dt: CGFloat) {
        // need to check distance before the deadzone guard or it never updates while standing
        let npcdx = characterPosition.x - npcPosition.x
        let npcdy = characterPosition.y - npcPosition.y
        isNPCInRange = sqrt(npcdx * npcdx + npcdy * npcdy) < 150 // 150 pts feels about right

        let dx = joystickMonitor.xyPoint.x
        let dy = joystickMonitor.xyPoint.y

        guard sqrt(dx * dx + dy * dy) > deadzone else {
            characterAnim = .idle
            return
        }

        let normX = dx / joystickSize
        let normY = dy / joystickSize

        // clamp so player doesn't walk off screen
        let newX = min(max(characterPosition.x + normX * moveSpeed * dt, charHalfW), sceneSize.width - charHalfW)
        let newY = min(max(characterPosition.y - normY * moveSpeed * dt, charHalfH), sceneSize.height - charHalfH)
        characterPosition = CGPoint(x: newX, y: newY)

        if normX < -0.1 { isFacingRight = false }
        else if normX > 0.1 { isFacingRight = true }

        characterAnim = .walking
    }

    func interact() {
        guard isNPCInRange else {
            print("not close enough to NPC")
            return
        }
        showDialogue = true
    }
}
