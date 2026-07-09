//
//  DialogueView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct DialogueView: View {

    @StateObject private var viewModel = DialogueViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("GPBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            characters
        }
        .overlay(alignment: panelAlignment) {
            bottomPanel
                .padding(.horizontal, 24)
                .padding(.top, panelAlignment == .top ? 84 : 0)
                .padding(.bottom, panelAlignment == .bottom ? 28 : 0)
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image("back_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
            }
            .padding(24)
        }
        .overlay {
            if viewModel.isEnded {
                ClosingView(
                    onBackToPlayground: { dismiss() },
                    onTryAgain: { viewModel.restart() }
                )
            }
        }
    }

    private var characters: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Image("0_Seer_Idle_000")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            Image("0_Goblin_Idle_000")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 16)
    }

    private var panelAlignment: Alignment {
        if case .narrative = viewModel.currentBeat { return .top }
        return .bottom
    }

    @ViewBuilder
    private var bottomPanel: some View {
        switch viewModel.currentBeat {
        case .narrative(let text):
            narrativePanel(text: text)
                .onTapGesture { viewModel.advance() }

        case .speech(let speaker, let text):
            speechPanel(speaker: speaker, text: text)
                .onTapGesture { viewModel.advance() }

        case .choice(let options):
            choicePanel(options: options)

        case .ending(let emotion):
            endingPanel(emotion: emotion)
        }
    }

    // box narration
    private func narrativePanel(text: String) -> some View {
        dialogueText(text, size: 34)
            .frame(maxWidth: 820)
            .padding(.horizontal, 72)
            .padding(.vertical, 54)
            .background(
                Image("narration_box").resizable()
            )
            .overlay(alignment: .trailing) {
                nextButton("narration_next_button", width: 200) { viewModel.advance() }
                    .offset(x: 80, y: 80)
            }
    }

    private func speechPanel(speaker: String, text: String) -> some View {
        dialogueText(text, size: 30)
            .padding(.horizontal, 56)
            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.25)
            .background(
                Image("joey_conversation_box").resizable()
            )
            .overlay(alignment: .topLeading) { nameBox(speaker) }
            .overlay(alignment: .bottomTrailing) {
                nextButton("conversation_next_button", width: 130) { viewModel.advance() }
                    .offset(x: 24, y: 24)
            }
    }

    private func choicePanel(options: [DecisionRoute]) -> some View {
        HStack(spacing: 24) {
            ForEach(options) { route in
                Button {
                    viewModel.choose(route)
                } label: {
                    Text(route.choiceText)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            Image("option_conversation_box").resizable()
                        )
                }
            }
        }
        .padding(.horizontal, 56)
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.25)
        .background(
            Image("joey_conversation_box").resizable()
        )
        .overlay(alignment: .topLeading) { nameBox(viewModel.playerName) }
    }

    private func nameBox(_ speaker: String) -> some View {
        Text(speaker)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
            .padding(.horizontal, 46)
            .padding(.vertical, 16)
            .background(
                Image("joey_name_box").resizable()
            )
            .offset(x: 32, y: -36)
    }

    private func endingPanel(emotion: String) -> some View {
        VStack(spacing: 14) {
            Text("— The End —")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text("Mia feels: \(emotion)")
                .font(.system(size: 18, design: .rounded))
                .foregroundStyle(.black.opacity(0.7))

            Button("Done") { dismiss() }
                .font(.headline)
                .foregroundStyle(.black)
                .padding(.horizontal, 28)
                .padding(.vertical, 11)
                .background(
                    Image("joey_name_box").resizable()
                )
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(
            Image("joey_conversation_box").resizable()
        )
    }

    private func dialogueText(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundStyle(.black.opacity(0.85))
            .multilineTextAlignment(.center)
    }

    private func nextButton(_ asset: String, width: CGFloat = 66, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: width)
        }
    }
}

#Preview {
    DialogueView()
}
