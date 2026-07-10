//
//  GameScene.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SpriteKit
import CoreImage

class GameScene: SKScene {

    weak var viewModel: GameViewModel?

    private var seerNode: SKSpriteNode!
    private var npcNode: SKSpriteNode!
    private var rangeAura: SKEffectNode!
    private var auraSprite: SKSpriteNode!
    private var auraVisible = false
    private var currentAnim: CharacterAnim = .idle
    private var cameraNode: SKCameraNode!

    // world is bigger than the screen so the camera actually has room to scroll
    private let worldMultiplier: CGFloat = 2.5
    private var worldSize: CGSize = .zero

    // lazy so they don't all load at once
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
        setupCamera()
    }

    private func setupBackground() {
        worldSize = CGSize(width: size.width * worldMultiplier, height: size.height * worldMultiplier)
        let bg = SKSpriteNode(imageNamed: "Cubby_Gameplay_Page_01_BG 1")
        if bg.size.width > 0 {
            // scale to cover the full world, not just the screen
            let fillScale = max(worldSize.width / bg.size.width, worldSize.height / bg.size.height)
            bg.setScale(fillScale)
        }
        bg.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        bg.zPosition = -10
        addChild(bg)
    }

    private func setupCharacter() {
        seerNode = SKSpriteNode(texture: idleFrames[0])
        seerNode.setScale(0.35)
        let startPos = CGPoint(x: worldSize.width / 2, y: worldSize.height * 0.38)
        seerNode.position = startPos
        seerNode.zPosition = 0
        addChild(seerNode)

        viewModel?.sceneSize = worldSize  // movement bounds = world, not screen
        viewModel?.characterPosition = startPos
        viewModel?.charHalfW = seerNode.size.width * 0.35 / 2
        viewModel?.charHalfH = seerNode.size.height * 0.35 / 2

        playAnim(.idle)
    }

    private func setupNPC() {
        npcNode = SKSpriteNode(texture: npcIdleFrames[0])
        npcNode.setScale(0.35)
        let npcPos = CGPoint(x: worldSize.width * 0.72, y: worldSize.height * 0.38)
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
        // duplicate of NPC sprite, same scale, tinted green
        // CIMorphologyMaximum pushes the outline outward so it peeks around the edges
        auraSprite = SKSpriteNode(texture: npcIdleFrames[0])
        auraSprite.setScale(0.35)
        auraSprite.color = UIColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1)
        auraSprite.colorBlendFactor = 1.0

        rangeAura = SKEffectNode()
        rangeAura.shouldEnableEffects = true
        if let morpho = CIFilter(name: "CIMorphologyMaximum") {
            morpho.setValue(6.0, forKey: kCIInputRadiusKey)
            rangeAura.filter = morpho
        }
        rangeAura.zPosition = -0.5
        rangeAura.position = npcNode.position
        rangeAura.alpha = 0
        rangeAura.addChild(auraSprite)
        addChild(rangeAura)
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.setScale(0.6) // zoom in so MC is clearly visible
        cameraNode.position = viewModel?.characterPosition ?? CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let vm = viewModel else { return }
        vm.tick(deltaTime: 1.0 / 60.0)
        seerNode.position = vm.characterPosition
        seerNode.xScale = vm.isFacingRight ? abs(seerNode.xScale) : -abs(seerNode.xScale)
        playAnim(vm.characterAnim)
        rangeAura.position = npcNode.position
        auraSprite.texture = npcNode.texture // sync outline with npc animation frame
        updateRangeAura(inRange: vm.isNPCInRange)
        followPlayer(vm.characterPosition)
    }

    private func followPlayer(_ pos: CGPoint) {
        // viewport size = scene size * camera scale (0.6 zoom)
        let halfViewW = size.width * cameraNode.xScale / 2
        let halfViewH = size.height * cameraNode.yScale / 2
        let camX = min(max(pos.x, halfViewW), worldSize.width - halfViewW)
        let camY = min(max(pos.y, halfViewH), worldSize.height - halfViewH)
        cameraNode.position = CGPoint(x: camX, y: camY)
    }

    private func updateRangeAura(inRange: Bool) {
        guard inRange != auraVisible else { return }
        auraVisible = inRange
        rangeAura.removeAllActions()

        if inRange {
            rangeAura.run(SKAction.fadeIn(withDuration: 0.2))
        } else {
            rangeAura.run(SKAction.fadeOut(withDuration: 0.2))
        }
    }

    // don't restart the animation if it's already playing
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
