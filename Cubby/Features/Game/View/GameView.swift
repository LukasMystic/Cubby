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

    @State private var viewModel = GameViewModel()

    // Separate from viewModel.showDialogue so we can coordinate the white-flash timing.
    @State private var dialoguePresented = false
    @State private var screenFlash: Double = 0

    // TipKit — popover tips for joystick and interact button.
    private let joystickTip = JoystickTip()
    private let interactTip = InteractTip()
    private let startGameTip = StartGameTip()

    // Prevent re-donating the joystick event on every walk frame.
    @State private var joystickEventDonated = false

    // Controls the custom glass "Start the Game!" banner.
    @State private var showStartBanner = false

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud

            // Glass "Start the Game!" banner — shown after the interact tip closes.
            if showStartBanner {
                VStack {
                    startBanner
                    Spacer()
                        .allowsHitTesting(false)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if dialoguePresented {
                DialogueView(onDismiss: { closeDialogue() })
                    .zIndex(1)
            }

            // White overlay sits on top of everything — animated separately from the view swap.
            Color.white
                .opacity(screenFlash)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .zIndex(2)
        }
        // When the game requests dialogue, run the flash-through-white transition.
        .onChange(of: viewModel.showDialogue) { _, newValue in
            guard newValue else { return }
            openDialogue()
        }
        // Donate the joystick event the first time the character starts walking.
        .onChange(of: viewModel.characterAnim) { _, anim in
            guard anim == .walking, !joystickEventDonated else { return }
            joystickEventDonated = true
            Task { await InteractTip.useJoystick.donate() }
        }
    }

    // MARK: - Start banner

    private var startBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
                .foregroundStyle(.blue)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Start the Game!")
                    .font(.custom("FredokaOne-Regular", size: 16))
                    .foregroundStyle(.primary)
                Text("You're all set. Go explore!")
                    .font(.custom("Playpen Sans", size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.25)) { showStartBanner = false }
                startGameTip.invalidate(reason: .actionPerformed)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 40)
        .padding(.top, 60)
    }

    // MARK: - Transition helpers

    private func openDialogue() {
        Task {
            withAnimation(.easeIn(duration: 0.18)) { screenFlash = 1 }
            try? await Task.sleep(nanoseconds: 200_000_000)
            dialoguePresented = true
            withAnimation(.easeOut(duration: 0.30)) { screenFlash = 0 }
        }
    }

    private func closeDialogue() {
        Task {
            withAnimation(.easeIn(duration: 0.18)) { screenFlash = 1 }
            try? await Task.sleep(nanoseconds: 200_000_000)
            dialoguePresented = false
            viewModel.showDialogue = false
            withAnimation(.easeOut(duration: 0.30)) { screenFlash = 0 }
        }
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
        .popoverTip(joystickTip, arrowEdge: .bottom)
    }

    // MARK: - Interact button

    private var interactButton: some View {
        Button {
            Task {
                await InteractTip.useInteract.donate()
                // Wait for the interact popover to finish closing before showing the start banner.
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                guard startGameTip.shouldDisplay else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showStartBanner = true
                }
            }
            viewModel.interact()
        } label: {
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
        .popoverTip(interactTip, arrowEdge: .bottom)
    }
}

#Preview {
    GameView()
}
