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

    // Separate from viewModel.showDialogue so we can coordinate the white-flash timing.
    @State private var dialoguePresented = false
    @State private var screenFlash: Double = 0

    // TipKit — each tip is shown exactly once, ever.
    private let joystickTip  = JoystickTip()
    private let interactTip  = InteractTip()
    private let startGameTip = StartGameTip()

    // Prevent re-donating the joystick event on every walk frame.
    @State private var joystickEventDonated = false

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()

            hud

            // StartGameTip shown as a banner near the top once both events are donated.
            VStack {
                TipView(startGameTip, arrowEdge: .top)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                Spacer()
            }
            .allowsHitTesting(false) // tips themselves handle their own taps

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
            // Donate interact event for TipKit sequencing, then attempt interaction.
            Task { await InteractTip.useInteract.donate() }
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
