//
//  GameView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import SpriteKit
import SwiftUIJoystick
import TipKit

struct GameView: View {
    private let joystickTip = JoystickTip()
    private let interactTip = InteractTip()
    private let startTip = StartGameTip()

    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud

            TipView(startTip)
                .padding(.horizontal, 40)
        }
        .fullScreenCover(isPresented: $viewModel.showDialogue) {
            DialogueView()
        }
    }

    // HUD: joystick bottom-left, interact button bottom-right
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

    private var joystick: some View {
        JoystickBuilder(
            monitor: viewModel.joystickMonitor,
            width: viewModel.joystickSize,
            shape: .circle,
            background: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 2.5))
            },
            foreground: {
                Circle()
                    .fill(Color.white.opacity(0.75))
                    .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
            },
            locksInPlace: false
        )
        .padding(.leading, 32)
        .padding(.bottom, 28)
        .popoverTip(joystickTip)
    }

    private var interactButton: some View {
        Button { viewModel.interact() } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 2.5))
                    .frame(width: viewModel.joystickSize, height: viewModel.joystickSize)

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.trailing, 32)
        .padding(.bottom, 28)
        .popoverTip(interactTip)
    }
}

#Preview {
    GameView()
}
