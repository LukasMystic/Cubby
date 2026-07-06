//
//  GameScene.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SpriteKit

class GameScene: SKScene {

    weak var viewModel: GameViewModel?

    private var seerNode: SKSpriteNode!
    private var npcNode: SKSpriteNode!
    private var currentAnim: CharacterAnim = .idle

    // Load sprite frames only when first needed
    private lazy var idleFrames: [SKTexture] = (0...17).map {
        SKTexture(imageNamed: "0_Seer_Idle_\(String(format: "%03d", $0))")
    }
    private lazy var walkFrames: [SKTexture] = (0...23).map {
        SKTexture(imageNamed: "0_Seer_Walking_\(String(format: "%03d", $0))")
    }
    private lazy var npcIdleFrames: [SKTexture] = (0...17).map {
        SKTexture(imageNamed: "0_Goblin_Idle_\(String(format: "%03d", $0))")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupCharacter()
        setupNPC()
    }

    private func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "GPBackground")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        if bg.size.width > 0 {
            bg.setScale(max(size.width / bg.size.width, size.height / bg.size.height))
        }
        bg.zPosition = -10
        addChild(bg)
    }

    private func setupCharacter() {
        seerNode = SKSpriteNode(texture: idleFrames[0])
        seerNode.setScale(0.35)
        let startPos = CGPoint(x: size.width / 2, y: size.height * 0.38)
        seerNode.position = startPos
        seerNode.zPosition = 0
        addChild(seerNode)

        // Let the ViewModel know the screen and character bounds for movement clamping
        viewModel?.sceneSize = size
        viewModel?.characterPosition = startPos
        viewModel?.charHalfW = seerNode.size.width * 0.35 / 2
        viewModel?.charHalfH = seerNode.size.height * 0.35 / 2

        playAnim(.idle)
    }

    private func setupNPC() {
        npcNode = SKSpriteNode(texture: npcIdleFrames[0])
        npcNode.setScale(0.35)
        let npcPos = CGPoint(x: size.width * 0.72, y: size.height * 0.38)
        npcNode.position = npcPos
        npcNode.zPosition = 0
        addChild(npcNode)

        // Tell the ViewModel where the NPC is so interact() can do a proximity check
        viewModel?.npcPosition = npcPos

        npcNode.run(
            SKAction.repeatForever(
                SKAction.animate(with: npcIdleFrames, timePerFrame: 1.0 / 12)
            ),
            withKey: "npcIdle"
        )
    }

    // Called every frame by SpriteKit
    override func update(_ currentTime: TimeInterval) {
        guard let vm = viewModel else { return }
        vm.tick(deltaTime: 1.0 / 60.0)
        seerNode.position = vm.characterPosition
        seerNode.xScale = vm.isFacingRight ? abs(seerNode.xScale) : -abs(seerNode.xScale)
        playAnim(vm.characterAnim)
    }

    // Only swap the animation when it actually changes — avoids restarting the same clip
    private func playAnim(_ anim: CharacterAnim) {
        guard anim != currentAnim else { return }
        currentAnim = anim

        seerNode.removeAction(forKey: "anim")
        let (frames, fps): ([SKTexture], Double) = anim == .idle
            ? (idleFrames, 12)
            : (walkFrames, 16)

        seerNode.run(
            SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 1.0 / fps)),
            withKey: "anim"
        )
    }
}
