//
//  GameView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import SpriteKit
import SwiftUIJoystick

// MARK: - Iris-wipe transition

/// A circle that grows from 0 to fully covering the screen, driven by `progress`.
private struct IrisWipeShape: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // Radius large enough to always cover the full rect at progress == 1.
        let maxRadius = hypot(rect.width, rect.height) / 2 * 1.05
        let r = maxRadius * progress
        var p = Path()
        p.addEllipse(in: CGRect(x: center.x - r, y: center.y - r,
                                width: r * 2, height: r * 2))
        return p
    }
}

private struct IrisRevealModifier: ViewModifier {
    let progress: CGFloat
    func body(content: Content) -> some View {
        content.clipShape(IrisWipeShape(progress: progress))
    }
}

extension AnyTransition {
    /// Circle expands from centre on insertion, contracts to centre on removal.
    static var irisReveal: AnyTransition {
        .modifier(
            active:   IrisRevealModifier(progress: 0),
            identity: IrisRevealModifier(progress: 1)
        )
    }
}

// MARK: - GameView

struct GameView: View {

    @State private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud

            if viewModel.showDialogue {
                DialogueView(onDismiss: {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        viewModel.showDialogue = false
                    }
                })
                .transition(.irisReveal)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: viewModel.showDialogue)
    }

    // MARK: - HUD

    private var hud: some View {
        VStack {
            Spacer()

            HStack(alignment: .bottom) {
                joystick
                Spacer()
                interactButton
            }
        }
    }

    // MARK: - Joystick

    private var joystick: some View {
        JoystickBuilder(
            monitor: viewModel.joystickMonitor,
            width: viewModel.joystickSize,
            shape: .circle,
            background: {
                Image("joystick_button_base")
                    .resizable()
                    .scaledToFit()
            },
            foreground: {
                // JoystickBuilder constrains the thumb to width/4 for layout,
                // but a fixed frame overflows that without clipping, making it visually larger.
                Image("joystick_button_point")
                    .resizable()
                    .scaledToFit()
                    .frame(width: viewModel.joystickSize * 0.42,
                           height: viewModel.joystickSize * 0.42)
            },
            locksInPlace: false
        )
        .padding(.leading, 32)
        .padding(.bottom, 28)
    }

    // MARK: - Interact button

    private var interactButton: some View {
        Button { viewModel.interact() } label: {
            ZStack {
                Image("interact_button_base")
                    .resizable()
                    .scaledToFit()
                Image("interact_button_hand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: viewModel.joystickSize * 0.52,
                           height: viewModel.joystickSize * 0.52)
            }
            .frame(width: viewModel.joystickSize, height: viewModel.joystickSize)
        }
        .padding(.trailing, 32)
        .padding(.bottom, 28)
    }
}

#Preview {
    GameView()
}
