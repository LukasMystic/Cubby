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

    @State private var viewModel = GameViewModel()
    @State private var showSavedBadge = false

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud

            if viewModel.isPaused {
                pauseOverlay
            }
            TipView(startTip)
                .padding(.horizontal, 40)
        }
        .fullScreenCover(isPresented: Bindable(viewModel).showDialogue) {
            DialogueView()
        }
    }

    // hud
    private var hud: some View {
        VStack {
            HStack {
                Spacer()
                pauseButton
            }
            .padding(.top, 16)
            .padding(.trailing, 20)

            Spacer()

            HStack(alignment: .bottom) {
                joystick
                Spacer()
                interactButton
            }
        }
    }

    private var pauseButton: some View {
        Button { viewModel.isPaused = true } label: {
            Image(systemName: "pause.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1.5))
        }
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 24) {

                // Title
                VStack(spacing: 6) {
                    Text("PAUSED")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.white.opacity(0.25))
                }

                // Menu buttons
                VStack(spacing: 12) {
                    pauseMenuButton(icon: "play.fill", label: "Resume", tint: .green) {
                        viewModel.isPaused = false
                    }

                    pauseMenuButton(
                        icon: showSavedBadge ? "checkmark.circle.fill" : "square.and.arrow.down.fill",
                        label: showSavedBadge ? "Saved!" : "Save",
                        tint: showSavedBadge ? .green : .blue
                    ) {
                        // auto-saved on decisions, this just shows the feedback badge
                        showSavedBadge = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSavedBadge = false
                        }
                    }

                    Divider().overlay(.white.opacity(0.15))

                    pauseMenuButton(icon: "house.fill", label: "Main Menu", tint: .orange) {
                        // TODO: Replace with navigation to MainMenuView
                        // e.g. path.removeLast() if using NavigationStack,
                        // or set a @State var showMainMenu = true and present it.
                        viewModel.isPaused = false
                    }
                }
            }
            .padding(28)
            .frame(width: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 10)
        }
    }

    private func pauseMenuButton(icon: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 28)

                Text(label)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        }
        .animation(.easeInOut(duration: 0.2), value: showSavedBadge)
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
