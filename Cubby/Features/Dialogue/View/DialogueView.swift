//
//  DialogueView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import UIKit

struct DialogueView: View {

    @State private var viewModel = DialogueViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var speakerOn = true
    @State private var lastSpeaker = ""

    private func isMia(_ speaker: String) -> Bool {
        speaker.lowercased().contains("mia")
    }

    private var activeSpeaker: String? {
        switch viewModel.currentBeat {
        case .speech(let speaker, _): return speaker
        case .choice:                 return lastSpeaker.isEmpty ? nil : lastSpeaker
        default:                      return nil
        }
    }

    private var panelAlignment: Alignment {
        if case .narrative = viewModel.currentBeat { return .top }
        return .bottom
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Cubby_Gameplay_NoCharacter 1")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 8, opaque: true)
                    .ignoresSafeArea()

                characters(geo: geo)
            }
            .overlay(alignment: panelAlignment) {
                bottomPanel(geo: geo)
                    .padding(.horizontal, 24)
                    .padding(.top,    panelAlignment == .top    ? 84 : 0)
                    .padding(.bottom, panelAlignment == .bottom ? 28 : 0)
            }
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image("Back_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72)
                }
                .padding(24)
            }
            .overlay(alignment: .topTrailing) {
                Button { speakerOn.toggle() } label: {
                    Image(speakerOn ? "Speaker_on_button" : "Speaker_off_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72)
                }
                .padding(24)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Characters
    // Fixed height on both images ensures they render at the same visual height
    // regardless of each asset's different aspect ratio.

    private func characters(geo: GeometryProxy) -> some View {
        let active   = activeSpeaker
        let charH    = geo.size.height * 0.82
        let miaDim   = active.map { isMia($0) ? 0.0 : -0.35 } ?? 0
        let joeyDim  = active.map { isMia($0) ? -0.35 : 0.0 } ?? 0

        return HStack(alignment: .bottom, spacing: 0) {
            Image("mia_1 2")
                .resizable()
                .scaledToFit()
                .frame(height: charH)
                .frame(maxWidth: .infinity)
                .brightness(miaDim)
                .animation(.easeInOut(duration: 0.3), value: miaDim)

            Image("joey 3")
                .resizable()
                .scaledToFit()
                .frame(height: charH)
                .frame(maxWidth: .infinity)
                .brightness(joeyDim)
                .animation(.easeInOut(duration: 0.3), value: joeyDim)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Panels

    @ViewBuilder
    private func bottomPanel(geo: GeometryProxy) -> some View {
        switch viewModel.currentBeat {
        case .narrative(let text):
            narrativePanel(text: text)
                .onTapGesture { viewModel.advance() }

        case .speech(let speaker, let text):
            speechPanel(speaker: speaker, text: text, geo: geo)
                .onTapGesture { viewModel.advance() }
                .onAppear { lastSpeaker = speaker }

        case .choice(let options):
            choicePanel(options: options, geo: geo)

        case .ending(let emotion):
            endingPanel(emotion: emotion)
        }
    }

    // MARK: - Narrative (top)

    private func narrativePanel(text: String) -> some View {
        dialogueText(text, size: 26)
            .frame(maxWidth: 820)
            .padding(.horizontal, 72)
            .padding(.vertical, 40)
            .background(Image("Narration_box").resizable())
    }

    // MARK: - Speech (bottom)

    private func speechPanel(speaker: String, text: String, geo: GeometryProxy) -> some View {
        let mia = isMia(speaker)
        return ZStack(alignment: .bottomTrailing) {
            Image(mia ? "Mia_dialogue_box" : "Joey_dialogue_box")
                .resizable()
                .frame(maxWidth: .infinity, minHeight: geo.size.height * 0.22)

            dialogueText(text, size: 26)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 56)
                .padding(.vertical, 32)

            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.orange)
                .padding(20)
        }
        // Name tag attached to the top-right edge of the bubble
        .overlay(alignment: .topTrailing) {
            nameBox(speaker, isMia: mia)
                .offset(x: -16, y: -22)
        }
    }

    // MARK: - Choices (bottom) — bare option buttons, no surrounding box

    private func choicePanel(options: [DecisionRoute], geo: GeometryProxy) -> some View {
        let mia = isMia(lastSpeaker)
        return HStack(spacing: 16) {
            ForEach(options) { route in
                Button {
                    captureScreen(for: route)
                    viewModel.choose(route)
                } label: {
                    ZStack {
                        Image(mia ? "Mia_option_button" : "Joey_option_button")
                            .resizable()
                            .aspectRatio(899.0 / 248.0, contentMode: .fit)

                        dialogueText(route.choiceText, size: 20, color: .white)
                            .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Ending (bottom)

    private func endingPanel(emotion: String) -> some View {
        VStack(spacing: 14) {
            Text("— The End —")
                .font(.custom("Fredoka", size: 30))
                .foregroundStyle(.black)

            Text("Mia feels: \(emotion)")
                .font(.custom("Playpen Sans", size: 22))
                .foregroundStyle(.black.opacity(0.7))

            Button("Done") { dismiss() }
                .font(.custom("Fredoka", size: 22))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 11)
                .background(Color.orange)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Image("Joey_dialogue_box").resizable())
    }

    // MARK: - Shared helpers

    private func dialogueText(_ text: String, size: CGFloat, color: Color = .black.opacity(0.85)) -> some View {
        Text(text)
            .font(.custom("Playpen Sans", size: size))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
    }

    private func nameBox(_ speaker: String, isMia: Bool) -> some View {
        ZStack {
            Image(isMia ? "Mia_name_box" : "Joey_name_box")
                .resizable()
                .aspectRatio(520.0 / 150.0, contentMode: .fit)
                .frame(width: 160)

            Text(speaker.uppercased())
                .font(.custom("Fredoka", size: 22))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Screenshot capture

    private func captureScreen(for route: DecisionRoute) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let img = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: false) }
        viewModel.saveDecisionScreenshot(img, targetFile: route.targetFile)
    }
}

#Preview {
    DialogueView()
}
