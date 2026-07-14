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

    private let canvasW: CGFloat = 2752
    private let canvasH: CGFloat = 2064

    //  SpriteKit world coordinate (origin bottom-left).
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

    // MARK: - Cross-fade shader helpers

    /// Creates a per-node shader that blends u_texture → u_next_texture via u_blend (0…1).
    /// Each node must get its own instance so uniforms are independent.
    private func makeCrossFadeShader() -> SKShader {
        let src = """
        uniform sampler2D u_next_texture;
        uniform float u_blend;
        void main() {
            vec4 current = texture2D(u_texture, v_tex_coord);
            vec4 next    = texture2D(u_next_texture, v_tex_coord);
            gl_FragColor = mix(current, next, u_blend) * v_color_mix;
        }
        """
        let shader = SKShader(source: src)
        shader.addUniform(SKUniform(name: "u_blend", float: 0))
        shader.addUniform(SKUniform(name: "u_next_texture", texture: SKTexture()))
        return shader
    }

    /// Runs a pixel-level cross-dissolve ping-pong between two textures forever.
    /// Replaces SKAction.animate for any 2-frame NPC sprite.
    private func runCrossFade(on node: SKSpriteNode,
                               tex0: SKTexture, tex1: SKTexture,
                               holdDuration: TimeInterval,
                               blendDuration: TimeInterval) {
        node.shader = makeCrossFadeShader()

        // One half-cycle: set current/next, hold, then smoothly blend across.
        func makeStep(current: SKTexture, next: SKTexture) -> SKAction {
            SKAction.sequence([
                SKAction.run {
                    node.texture = current
                    node.shader?.uniformNamed("u_next_texture")?.textureValue = next
                    node.shader?.uniformNamed("u_blend")?.floatValue = 0
                },
                SKAction.wait(forDuration: holdDuration),
                SKAction.customAction(withDuration: blendDuration) { n, elapsed in
                    let p = min(Float(elapsed) / Float(blendDuration), 1.0)
                    (n as? SKSpriteNode)?.shader?.uniformNamed("u_blend")?.floatValue = p
                }
            ])
        }

        node.run(
            SKAction.repeatForever(SKAction.sequence([
                makeStep(current: tex0, next: tex1),
                makeStep(current: tex1, next: tex0)
            ])),
            withKey: "crossfade"
        )
    }

    // NPC setup

    private func setupPlaygroundCharacters() {
        let charH: CGFloat = 420

        func makeNPC(_ names: [String], height: CGFloat = charH) -> (SKSpriteNode, [SKTexture]) {
            let textures = names.map { SKTexture(imageNamed: $0) }
            let node = SKSpriteNode(texture: textures[0])
            let h = node.size.height
            node.setScale(h > 0 ? height * bgScale / h : bgScale)
            return (node, textures)
        }

        //Jennie on swing
        let (jennie, jennieTextures) = makeNPC(["NPC_Jennie_001", "NPC_Jennie_002"])
        jennie.position  = cw(720, 870)
        jennie.zPosition = -3.9
        addChild(jennie)
        runCrossFade(on: jennie, tex0: jennieTextures[0], tex1: jennieTextures[1],
                     holdDuration: 0.30, blendDuration: 0.40)

        //Melanie on slide
        let (melanie, melanieTextures) = makeNPC(["NPC_Melanie_001", "NPC_Melanie_002"])
        let slideTop    = cw(2050, 680)
        let slideBottom = cw(1430, 1020)
        melanie.position  = slideTop
        melanie.zPosition = -4.5
        addChild(melanie)
        let slideDown = SKAction.move(to: slideBottom, duration: 1.8)
        slideDown.timingMode = .easeIn
        melanie.run(slideDown)
        runCrossFade(on: melanie, tex0: melanieTextures[0], tex1: melanieTextures[1],
                     holdDuration: 0.25, blendDuration: 0.35)

        //Ihsan playing ball
        let (ihsan, ihsanTextures) = makeNPC(["NPC_Ihsan_001", "NPC_Ihsan_002"], height: 450)
        ihsan.position  = cw(2200, 1340)
        ihsan.zPosition = -0.5
        addChild(ihsan)
        runCrossFade(on: ihsan, tex0: ihsanTextures[0], tex1: ihsanTextures[1],
                     holdDuration: 0.28, blendDuration: 0.30)

        // Mia in sandbox
        let (mia, miaTextures) = makeNPC(["NPC_Mia_001", "NPC_Mia_002"])
        mia.position  = cw(1180, 1220)
        mia.zPosition = -0.9
        addChild(mia)
        runCrossFade(on: mia, tex0: miaTextures[0], tex1: miaTextures[1],
                     holdDuration: 0.55, blendDuration: 0.55)
        miaNode = mia
    }

  
    private var depthScaleFront: CGFloat = 0.11
    private var depthScaleBack: CGFloat  = 0.060
 // returns the node scale for a given world-Y position
    private func depthScale(for y: CGFloat) -> CGFloat {
        guard let vm = viewModel, vm.groundMax > vm.groundMin else { return depthScaleFront }
        let t = (y - vm.groundMin) / (vm.groundMax - vm.groundMin) // 0 = front, 1 = back
        return depthScaleFront + (depthScaleBack - depthScaleFront) * t
    }

    private func setupCharacter() {
        seerNode = SKSpriteNode(texture: idleFrames[0])

        // Scale Joey
        let npcHeight: CGFloat = 520
        depthScaleFront = (npcHeight * bgScale) / seerNode.size.height
        depthScaleBack  = depthScaleFront * 0.545

        groundY = size.height * 0.40
        let startPos = CGPoint(x: worldSize.width * 0.70, y: groundY)
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
        viewModel?.npcPosition = miaNode.position
    }

    private func setupRangeAura() {
        exclamationMark = SKSpriteNode(imageNamed: "Exclamation_mark")
        exclamationMark.zPosition = -0.1  // behind Joey (z=0), in front of Mia (z=-0.9)
        exclamationMark.alpha = 0
        exclamationMark.setScale(0.22)
        exclamationMark.position = CGPoint(
            x: miaNode.position.x,
            y: miaNode.position.y + miaNode.size.height * miaNode.yScale * 0.5 + 120
        )
        addChild(exclamationMark)

        // Pulse scale
        let big  = SKAction.scale(to: 0.26, duration: 0.35)
        let norm = SKAction.scale(to: 0.20, duration: 0.35)
        big.timingMode  = .easeInEaseOut
        norm.timingMode = .easeInEaseOut
        exclamationMark.run(SKAction.repeatForever(SKAction.sequence([big, norm])), withKey: "pulse")

        // Upward float
        let floatUp   = SKAction.moveBy(x: 0, y: 18, duration: 0.65)
        let floatDown = SKAction.moveBy(x: 0, y: -18, duration: 0.65)
        floatUp.timingMode   = .easeInEaseOut
        floatDown.timingMode = .easeInEaseOut
        exclamationMark.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatDown])), withKey: "float")
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
