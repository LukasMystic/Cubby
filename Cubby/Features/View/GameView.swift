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
    private let joystickTip = joystickTip()
    private let interactTip = interactTip()

    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud
            if viewModel.isShowingDialogue, let line = viewModel.currentLine {
                DialogueOverlay(line: line) {
                    viewModel.advanceDialogue()
                }
            }
        }
    }

    // hud

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

// Dialogue -> for later
private struct DialogueOverlay: View {
    let line: DialogueLine
    let onTap: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(line.speaker)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(line.text)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.bottom, 220)
            }
        }
    }
}

#Preview {
    GameView()
}
