//
//  GameViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SpriteKit
import SwiftUIJoystick
import Observation

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

    var sceneSize: CGSize = .zero
    var charHalfW: CGFloat = 40
    var charHalfH: CGFloat = 60
    var groundY: CGFloat = 0
    var groundMin: CGFloat = 0
    var groundMax: CGFloat = 0

    var npcPosition: CGPoint = .zero
    var isNPCInRange: Bool = false

    private let moveSpeed: CGFloat = 220
    private let deadzone: CGFloat = 10
    private var prevAnim: CharacterAnim = .idle

    let audioManager = AudioManager()
    var showDialogue = false

    init() {
        joystickMonitor = JoystickMonitor()
        let s = GameScene()
        s.scaleMode = .resizeFill
        gameScene = s
        s.viewModel = self
    }

    func tick(deltaTime dt: CGFloat) {
        let npcdx = characterPosition.x - npcPosition.x
        let npcdy = characterPosition.y - npcPosition.y
        isNPCInRange = sqrt(npcdx * npcdx + npcdy * npcdy) < 150

        let dx = joystickMonitor.xyPoint.x
        let dy = joystickMonitor.xyPoint.y

        guard sqrt(dx * dx + dy * dy) > deadzone else {
            characterAnim = .idle
            audioManager.tick(dt: Double(dt), anim: .idle, isNPCInRange: isNPCInRange)
            prevAnim = .idle
            return
        }

        let normX = dx / joystickSize
        let normY = dy / joystickSize

        let newX = min(max(characterPosition.x + normX * moveSpeed * dt, charHalfW), sceneSize.width - charHalfW)
        let newY = min(max(characterPosition.y - normY * moveSpeed * dt * 0.4, groundMin), groundMax)
        characterPosition = CGPoint(x: newX, y: newY)

        if normX < -0.1 { isFacingRight = false }
        else if normX > 0.1 { isFacingRight = true }

        if prevAnim == .idle { audioManager.playJoystickStart() }
        characterAnim = .walking
        audioManager.tick(dt: Double(dt), anim: .walking, isNPCInRange: isNPCInRange)
        prevAnim = .walking
    }

    func interact() {
        guard isNPCInRange else {
            print("not close enough to NPC")
            return
        }
        showDialogue = true
    }
}
