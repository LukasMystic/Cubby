import SwiftUI
import SpriteKit
import SwiftUIJoystick
import TipKit

struct GameView: View {

    @State private var viewModel = GameViewModel()
    @Environment(AppRouter.self) private var router
    @State private var screenFlash: Double = 0

    private let joystickTip = JoystickTip()
    private let interactTip = InteractTip()
    private let startGameTip = StartGameTip()
    @State private var joystickEventDonated = false
    @State private var showStartBanner = false

    private var dialoguePresented: Bool { router.current == .dialogue }
    private var storybookPresented: Bool { router.current == .storybook }
    private var closingPresented: Bool { router.current == .closing }

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()
            hud
            if showStartBanner {
                VStack {
                    startBanner
                    Spacer()
                        .allowsHitTesting(false)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if dialoguePresented {
                DialogueView(
                    onDismiss: { closeToGameplay() },
                    onStoryEnd: { openStorybook() }
                )
                .zIndex(1)
            }

            if storybookPresented {
                StorybookView(
                    viewModel: StorybookViewModel.fromUserProgress(),
                    onFinish: { openClosing() }
                )
                .zIndex(1)
            }

            if closingPresented {
                ClosingView(
                    onBackToPlayground: { closeToGameplay() },
                    onTryAgain: { tryAgain() }
                )
                .zIndex(1)
            }

            Color.white
                .opacity(screenFlash)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .zIndex(2)
        }
        .onChange(of: viewModel.showDialogue) { _, newValue in
            guard newValue else { return }
            openDialogue()
        }
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

    // MARK: - Transitions

    private func flash(_ action: @escaping () -> Void) {
        Task {
            withAnimation(.easeIn(duration: 0.18)) { screenFlash = 1 }
            try? await Task.sleep(nanoseconds: 200_000_000)
            action()
            withAnimation(.easeOut(duration: 0.30)) { screenFlash = 0 }
        }
    }

    private func openDialogue() {
        flash { router.current = .dialogue }
    }

    private func openStorybook() {
        flash { router.current = .storybook }
    }

    private func openClosing() {
        flash { router.current = .closing }
    }

    private func closeToGameplay() {
        flash {
            router.current = .game
            viewModel.showDialogue = false
        }
    }

    private func tryAgain() {
        flash { router.current = .dialogue }   // fresh DialogueView → fresh DialogueViewModel → new playthrough
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

    private var interactButton: some View {
        Button {
            Task {
                await InteractTip.useInteract.donate()
                interactTip.invalidate(reason: .actionPerformed)
                try? await Task.sleep(nanoseconds: 400_000_000)
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
        .environment(AppRouter())
}
