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
    private var miaNode: SKSpriteNode!
    private var exclamationMark: SKSpriteNode!
    private var exclamVisible = false
    private var currentAnim: CharacterAnim = .idle
    private var cameraNode: SKCameraNode!

    private var worldSize: CGSize = .zero
    private var groundY: CGFloat = 0
    private var bgScale: CGFloat = 1.0

    // Joey sprite sheet: 5 frames wide (frame 0 = idle, frames 1-4 = walk).
    private lazy var idleFrames: [SKTexture] = {
        let sheet = SKTexture(imageNamed: "WC_Joey_001_Idle1 2")
        let fw = CGFloat(1.0 / 5.0)
        return [SKTexture(rect: CGRect(x: 0, y: 0, width: fw, height: 1), in: sheet)]
    }()
    private lazy var walkFrames: [SKTexture] = {
        let sheet = SKTexture(imageNamed: "WC_Joey_001_Idle1 2")
        let fw = CGFloat(1.0 / 5.0)
        let fwd = (1...4).map { i in
            SKTexture(rect: CGRect(x: CGFloat(i) * fw, y: 0, width: fw, height: 1), in: sheet)
        }
        // ping-pong [1,2,3,4,3,2] — avoids the jarring snap from frame 4 back to frame 1
        return fwd + Array(fwd.dropFirst().dropLast().reversed())
    }()

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupBackground()
        setupPlaygroundCharacters()
        setupCharacter()
        setupNPC()
        setupRangeAura()
        setupCamera()
    }

    // All new Gameplay assets are 2752×2064 full-canvas composites.
    private let canvasW: CGFloat = 2752
    private let canvasH: CGFloat = 2064

    // Canvas pixel (origin top-left) → SpriteKit world coordinate (origin bottom-left).
    private func cw(_ cx: CGFloat, _ cy: CGFloat) -> CGPoint {
        CGPoint(x: cx * bgScale, y: (canvasH - cy) * bgScale)
    }

    private func setupBackground() {
        let ref = SKSpriteNode(imageNamed: "260709_Cubby_Gameplay_01_BG")
        bgScale = ref.size.height > 0 ? size.height / ref.size.height : 1.0
        let scaledW = ref.size.width > 0 ? ref.size.width * bgScale : size.width
        worldSize = CGSize(width: scaledW, height: size.height)
        let center = CGPoint(x: worldSize.width / 2, y: size.height / 2)

        // All static layers are 2752×2064 full-canvas — stack at center.
        let staticLayers: [(String, CGFloat)] = [
            ("260709_Cubby_Gameplay_01_BG",         -10),
            ("260709_Cubby_Gameplay_02_Ground",      -9),
            ("260709_Cubby_Gameplay_03_Shadows",     -8),
            ("260709_Cubby_Gameplay_03b_Grass",      -7),
            ("260709_Cubby_Gameplay_05_Slides",      -5),
            ("260709_Cubby_Gameplay_06_Box",         -3),
            ("260709_Cubby_Gameplay_07_BlockBlue",   -2),
            ("260709_Cubby_Gameplay_07_BlockGreen",  -2),
            ("260709_Cubby_Gameplay_07_BlockRed",    -2),
            ("260709_Cubby_Gameplay_07_BlockYellow", -2),
            ("260709_Cubby_Gameplay_08_Trees",        8),
            ("260709_Cubby_Gameplay_09_Bushes",       9),
        ]
        for (name, z) in staticLayers {
            let node = SKSpriteNode(imageNamed: name)
            node.setScale(bgScale)
            node.position = center
            node.zPosition = z
            addChild(node)
        }

        // All three swing frames are static — only Jennie's character sprite animates on the pivot.
        for name in ["260709_Cubby_Gameplay_04_Swing01",
                     "260709_Cubby_Gameplay_04_Swing02",
                     "260709_Cubby_Gameplay_04_Swing03"] {
            let n = SKSpriteNode(imageNamed: name)
            n.setScale(bgScale)
            n.position = center
            n.zPosition = -4
            addChild(n)
        }
    }

    private func setupPlaygroundCharacters() {
        // NPC sprites are cropped (not full-canvas).
        // Scale = target character height in canvas / sprite texture height.
        // charHeightInCanvas ≈ 420px at 2752×2064 — estimated from the design reference.
        let charH: CGFloat = 420

        func makeNPC(_ names: [String], height: CGFloat = charH) -> (SKSpriteNode, [SKTexture]) {
            let textures = names.map { SKTexture(imageNamed: $0) }
            let node = SKSpriteNode(texture: textures[0])
            let h = node.size.height
            node.setScale(h > 0 ? height * bgScale / h : bgScale)
            return (node, textures)
        }

        // ── Jennie on swing — static (swing background doesn't animate) ──────────
        let (jennie, jennieTextures) = makeNPC(["NPC_Jennie_001", "NPC_Jennie_002"])
        jennie.position  = cw(720, 870)
        jennie.zPosition = -3.9
        addChild(jennie)
        jennie.run(SKAction.repeatForever(SKAction.animate(with: jennieTextures, timePerFrame: 0.4)))

        // ── Melanie on slide ───────────────────────────────────────────────────
        // The slide goes from the TOP-RIGHT of the climbing frame DOWN-LEFT to the ground.
        // Canvas measured: top ≈ (2050, 830), bottom ≈ (1760, 1220).
        let (melanie, melanieTextures) = makeNPC(["NPC_Melanie_001", "NPC_Melanie_002"])
        let slideTop    = cw(2050, 680)
        let slideBottom = cw(1430, 1020)
        melanie.position  = slideTop
        melanie.zPosition = -4.5
        addChild(melanie)
        let slideDown = SKAction.move(to: slideBottom, duration: 1.8)
        slideDown.timingMode = .easeIn
        melanie.run(slideDown)
        melanie.run(SKAction.repeatForever(SKAction.animate(with: melanieTextures, timePerFrame: 0.6)))

        // ── Ihsan playing ball (canvas ≈ 2200, 1340) ──────────────────────────
        let (ihsan, ihsanTextures) = makeNPC(["NPC_Ihsan_001", "NPC_Ihsan_002"], height: 600)
        ihsan.position  = cw(2200, 1340)
        ihsan.zPosition = -0.5
        addChild(ihsan)
        ihsan.run(SKAction.repeatForever(SKAction.animate(with: ihsanTextures, timePerFrame: 0.5)))

        // ── Mia in sandbox (canvas ≈ 1020, 1380) ──────────────────────────────
        let (mia, miaTextures) = makeNPC(["NPC_Mia_001", "NPC_Mia_002"])
        mia.position  = cw(1180, 1220)
        mia.zPosition = -0.9
        addChild(mia)
        mia.run(SKAction.repeatForever(SKAction.animate(with: miaTextures, timePerFrame: 0.8)))
        miaNode = mia
    }

    // Joey's sprite sheet frame is 1300×2480 pts — much larger than the old Seer sprites.
    // Recalibrated so MC appears ~270 pts tall at front, ~150 pts at back.
    private let depthScaleFront: CGFloat = 0.11
    private let depthScaleBack: CGFloat  = 0.060

    // returns the node scale for a given world-Y position
    private func depthScale(for y: CGFloat) -> CGFloat {
        guard let vm = viewModel, vm.groundMax > vm.groundMin else { return depthScaleFront }
        let t = (y - vm.groundMin) / (vm.groundMax - vm.groundMin) // 0 = front, 1 = back
        return depthScaleFront + (depthScaleBack - depthScaleFront) * t
    }

    private func setupCharacter() {
        seerNode = SKSpriteNode(texture: idleFrames[0])
        groundY = size.height * 0.40
        let startPos = CGPoint(x: worldSize.width * 0.35, y: groundY)
        seerNode.position = startPos
        seerNode.zPosition = 0
        addChild(seerNode)

        viewModel?.sceneSize = worldSize
        viewModel?.characterPosition = startPos
        viewModel?.groundY = groundY
        // Y collision bounds: keep player inside the visible playground area.
        // groundMin = foreground overlap edge, groundMax = back of the playground structure.
        viewModel?.groundMin = size.height * 0.30
        viewModel?.groundMax = size.height * 0.54
        // use front (max) scale for movement bounds
        viewModel?.charHalfW = seerNode.size.width * depthScaleFront / 2
        viewModel?.charHalfH = seerNode.size.height * depthScaleFront / 2

        playAnim(.idle)
    }

    private func setupNPC() {
        npcNode = miaNode
        viewModel?.npcPosition = miaNode.position
    }

    private func setupRangeAura() {
        exclamationMark = SKSpriteNode(imageNamed: "Exclamation_mark")
        exclamationMark.zPosition = 10
        exclamationMark.alpha = 0
        // setScale to ~70 pts tall (sprite is 317 pts at 1x)
        exclamationMark.setScale(0.22)
        // position above Mia's head (anchor is center; half-height gets to top edge)
        exclamationMark.position = CGPoint(
            x: miaNode.position.x,
            y: miaNode.position.y + miaNode.size.height * miaNode.yScale * 0.5 + 50
        )
        addChild(exclamationMark)
        let big  = SKAction.scale(to: 0.26, duration: 0.35)
        let norm = SKAction.scale(to: 0.20, duration: 0.35)
        big.timingMode  = .easeInEaseOut
        norm.timingMode = .easeInEaseOut
        exclamationMark.run(SKAction.repeatForever(SKAction.sequence([big, norm])), withKey: "pulse")
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.setScale(0.75) // zoomed out to review NPC positions
        cameraNode.position = viewModel?.characterPosition ?? CGPoint(x: worldSize.width / 2, y: size.height / 2)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let vm = viewModel else { return }
        vm.tick(deltaTime: 1.0 / 60.0)
        seerNode.position = vm.characterPosition
        seerNode.xScale = vm.isFacingRight ? depthScaleFront : -depthScaleFront
        seerNode.yScale = depthScaleFront
        playAnim(vm.characterAnim)
        updateRangeAura(inRange: vm.isNPCInRange)
        followPlayer(vm.characterPosition)
    }

    private func followPlayer(_ pos: CGPoint) {
        let halfViewW = size.width * cameraNode.xScale / 2
        let halfViewH = size.height * cameraNode.yScale / 2
        let camX = min(max(pos.x, halfViewW), worldSize.width - halfViewW)
        let camY = min(max(pos.y, halfViewH), worldSize.height - halfViewH)
        cameraNode.position = CGPoint(x: camX, y: camY)
    }

    private func updateRangeAura(inRange: Bool) {
        guard inRange != exclamVisible else { return }
        exclamVisible = inRange
        exclamationMark.run(
            inRange ? SKAction.fadeIn(withDuration: 0.2) : SKAction.fadeOut(withDuration: 0.2),
            withKey: "visibility"
        )
    }

    // don't restart the animation if it's already playing
    private func playAnim(_ anim: CharacterAnim) {
        guard anim != currentAnim else { return }
        currentAnim = anim

        seerNode.removeAction(forKey: "anim")
        let (frames, fps): ([SKTexture], Double) = anim == .idle
            ? (idleFrames, 4)
            : (walkFrames, 6)

        seerNode.run(
            SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 1.0 / fps)),
            withKey: "anim"
        )
    }
}
