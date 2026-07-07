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
    private var rangeAura: SKShapeNode!
    private var auraVisible = false
    private var currentAnim: CharacterAnim = .idle

    // Load sprite frames ONLY when first needed
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
        setupRangeAura()
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

        viewModel?.npcPosition = npcPos

        npcNode.run(
            SKAction.repeatForever(
                SKAction.animate(with: npcIdleFrames, timePerFrame: 1.0 / 12)
            ),
            withKey: "npcIdle"
        )
    }

    private func setupRangeAura() {
        // Flat ellipse at the MC's feet — sits behind the sprite so it looks like a ground glow
        let halfH = seerNode.size.height * 0.35 / 2
        let ellipseRect = CGRect(x: -42, y: -(halfH + 8), width: 84, height: 26)
        rangeAura = SKShapeNode(ellipseIn: ellipseRect)
        rangeAura.fillColor  = UIColor(red: 0.45, green: 0.85, blue: 1.0, alpha: 0.55)
        rangeAura.strokeColor = UIColor(red: 0.3, green: 0.75, blue: 1.0, alpha: 0.9)
        rangeAura.lineWidth  = 2
        rangeAura.zPosition  = -1   // drawn behind the character sprite
        rangeAura.position   = seerNode.position
        rangeAura.alpha      = 0    // hidden until in range
        addChild(rangeAura)
    }

    // Called every frame by SpriteKit
    override func update(_ currentTime: TimeInterval) {
        guard let vm = viewModel else { return }
        vm.tick(deltaTime: 1.0 / 60.0)
        seerNode.position = vm.characterPosition
        seerNode.xScale = vm.isFacingRight ? abs(seerNode.xScale) : -abs(seerNode.xScale)
        playAnim(vm.characterAnim)
        // Aura follows the MC every frame
        rangeAura.position = vm.characterPosition
        // updateRangeAura(inRange: vm.isNPCInRange)
    }

    // Fades the ground aura in/out when the MC crosses the interact threshold
    private func updateRangeAura(inRange: Bool) {
        guard inRange != auraVisible else { return }
        auraVisible = inRange
        rangeAura.removeAllActions()

        if inRange {
            rangeAura.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.25),
                SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ]))
            ]))
        } else {
            rangeAura.run(SKAction.fadeOut(withDuration: 0.25))
        }
    }

    // Only swaps animation when it actually changes — avoids restarting the same clip
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
