//
//  GameScene.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SpriteKit
import SwiftUIJoystick

class GameScene: SKScene {
    weak var joystickMonitor: JoystickMonitor?

    private var seerNode: SKSpriteNode!

    private enum AnimState: Equatable { case idle, walking }
    private var animState: AnimState = .idle

    private lazy var idleFrames: [SKTexture] = (0...17).map {
        SKTexture(imageNamed: "0_Seer_Idle_\(String(format: "%03d", $0))")
    }
    private lazy var walkFrames: [SKTexture] = (0...23).map {
        SKTexture(imageNamed: "0_Seer_Walking_\(String(format: "%03d", $0))")
    }

    private let moveSpeed: CGFloat = 220
    private let deadzone: CGFloat = 10
    private let joystickWidth: CGFloat = 150

    private var charHalfW: CGFloat = 40
    private var charHalfH: CGFloat = 60

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupCharacter()
    }

    private func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "GPBackground")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        if bg.size.width > 0 {
            let scale = max(size.width / bg.size.width, size.height / bg.size.height)
            bg.setScale(scale)
        }
        bg.zPosition = -10
        addChild(bg)
    }

    private func setupCharacter() {
        seerNode = SKSpriteNode(texture: idleFrames[0])
        seerNode.setScale(0.35)
        seerNode.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        seerNode.zPosition = 0
        addChild(seerNode)

        charHalfW = seerNode.size.width * 0.35 / 2
        charHalfH = seerNode.size.height * 0.35 / 2

        playAnim(.idle, force: true)
    }

    private func playAnim(_ state: AnimState, force: Bool = false) {
        guard state != animState || force else { return }
        animState = state

        seerNode.removeAction(forKey: "anim")
        let (frames, fps): ([SKTexture], Double) = state == .idle
            ? (idleFrames, 12)
            : (walkFrames, 16)

        seerNode.run(
            SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 1.0 / fps)),
            withKey: "anim"
        )
    }

    override func update(_ currentTime: TimeInterval) {
        guard let monitor = joystickMonitor else { return }

        let dx = monitor.xyPoint.x
        let dy = monitor.xyPoint.y
        let magnitude = sqrt(dx * dx + dy * dy)

        guard magnitude > deadzone else {
            playAnim(.idle)
            return
        }

        let normX = dx / joystickWidth
        let normY = dy / joystickWidth
        let dt: CGFloat = 1.0 / 60.0

        let newX = min(max(seerNode.position.x + normX * moveSpeed * dt,
                           charHalfW), size.width - charHalfW)

        let newY = min(max(seerNode.position.y - normY * moveSpeed * dt,
                           charHalfH), size.height - charHalfH)
        seerNode.position = CGPoint(x: newX, y: newY)

        if normX < -0.1 {
            seerNode.xScale = -abs(seerNode.xScale)
        } else if normX > 0.1 {
            seerNode.xScale = abs(seerNode.xScale)
        }

        playAnim(.walking)
    }
}
