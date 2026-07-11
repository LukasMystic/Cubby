//
//  DialogueView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import UIKit

struct DialogueView: View {

    /// When set, this closure is used instead of the environment dismiss action.
    /// Pass it when presenting the view inline (e.g. inside a ZStack) rather than via fullScreenCover.
    var onDismiss: (() -> Void)? = nil

    @State private var viewModel = DialogueViewModel()
    @Environment(\.dismiss) private var envDismiss
    @State private var speakerOn = true
    @State private var lastSpeaker = ""
    // Tracks the rendered height of the speech bubble so the name box
    // can be positioned past the transparent tail area (35% from top).
    @State private var speechBoxHeight: CGFloat = 180

    // Typewriter
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var typewriterKey = 0

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
        switch viewModel.currentBeat {
        case .narrative: return .top
        case .choice:    return .center
        default:         return .bottom
        }
    }

    private var currentBeatText: String {
        switch viewModel.currentBeat {
        case .narrative(let text): return text
        case .speech(_, let text): return text
        default: return ""
        }
    }

    private func dismissSelf() {
        if let onDismiss { onDismiss() } else { envDismiss() }
    }

    private func handleAdvance() {
        guard !isTyping else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.advance()
        }
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
                    .padding(.top,    panelAlignment == .top    ? 140 : 0)
                    .padding(.bottom, panelAlignment == .bottom ? 28 : 0)
                    .id(viewModel.beatCounter)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            .task(id: typewriterKey) {
                let fullText = currentBeatText
                guard !fullText.isEmpty else { return }
                displayedText = ""
                isTyping = true
                for char in fullText {
                    if Task.isCancelled { break }
                    displayedText.append(char)
                    try? await Task.sleep(nanoseconds: 30_000_000) // 30 ms per character
                }
                isTyping = false
            }
            .onChange(of: viewModel.beatCounter) { _, _ in
                typewriterKey += 1
            }
            .overlay(alignment: .topLeading) {
                Button { dismissSelf() } label: {
                    Image("Back_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96)
                }
                .padding(24)
            }
            .overlay(alignment: .topTrailing) {
                Button { speakerOn.toggle() } label: {
                    Image(speakerOn ? "Speaker_on_button" : "Speaker_off_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96)
                }
                .padding(24)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Characters

    private func characters(geo: GeometryProxy) -> some View {
        let active   = activeSpeaker
        // Mia artwork fills 75% of her frame; Joey fills 94.5% of his.
        // Scale Joey's frame down by 0.794 so both characters appear the same visual height.
        let miaH    = geo.size.height * 0.70
        let joeyH   = geo.size.height * 0.56
        let miaDim  = active.map { isMia($0) ?  0.0 : -0.35 } ?? 0
        let joeyDim = active.map { isMia($0) ? -0.35 :  0.0 } ?? 0

        // Align both characters so their feet sit on the same ground line.
        // Mia's image has 9.75% bottom padding; Joey's has only 2.64%.
        // With bottom-alignment, Joey's feet are lower — lift him up by the difference.
        // Expression assets (EX_Mia_*) fill ~98% of their canvas vs 75% for mia_1 2.
        // Scale their frame down so the visible character height matches: 0.75 / 0.98 ≈ 0.76.
        // Add equivalent bottom padding so the foot-to-frame-bottom distance stays the same,
        // keeping joeyLift correct without any other changes.
        let isExprAsset = !viewModel.miaEmotion.isEmpty
        let miaFrameH   = miaH * (isExprAsset ? 0.76 : 1.0)
        let miaExtraPad: CGFloat = isExprAsset ? miaH * 0.0975 : 0
        // Expression assets are narrower (portrait ~1:2 vs mia_1 2's ~3:4), so their
        // rendered image starts further left. Shift right to match the original's position.
        let miaLeadPad: CGFloat = isExprAsset ? 20 + miaH * 0.20 : 20

        let miaFootPad  = miaH  * 0.0975
        let joeyFootPad = joeyH * 0.0264
        let joeyLift    = miaFootPad - joeyFootPad

        return HStack(alignment: .bottom, spacing: 0) {
            Image(viewModel.miaImageAssetName)
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(height: miaFrameH)
                .padding(.bottom, miaExtraPad)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, miaLeadPad)
                .brightness(miaDim)
                .animation(.easeInOut(duration: 0.3), value: miaDim)
                .animation(.easeInOut(duration: 0.4), value: viewModel.miaEmotion)

            Image("joey 3")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(height: joeyH)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 60)
                .brightness(joeyDim)
                .animation(.easeInOut(duration: 0.3), value: joeyDim)
                .padding(.bottom, joeyLift)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Panels

    @ViewBuilder
    private func bottomPanel(geo: GeometryProxy) -> some View {
        switch viewModel.currentBeat {
        case .narrative:
            narrativePanel(text: displayedText, geo: geo)
                .onTapGesture { handleAdvance() }

        case .speech(let speaker, _):
            speechPanel(speaker: speaker, text: displayedText, geo: geo)
                .onTapGesture { handleAdvance() }
                .onAppear { lastSpeaker = speaker }

        case .choice(let options):
            choicePanel(options: options, geo: geo)

        case .ending(let emotion):
            endingPanel(emotion: emotion)
        }
    }

    // MARK: - Narrative (top)

    private func narrativePanel(text: String, geo: GeometryProxy) -> some View {
        Image("Narration_box")
            .resizable()
            .aspectRatio(1711.0 / 410.0, contentMode: .fit)
            .frame(maxWidth: geo.size.width * 0.75)
            .overlay {
                dialogueText(text, size: 24)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .padding(.horizontal, 52)
                    .padding(.vertical, 10)
            }
            .overlay(alignment: .bottomTrailing) {
                Image("Next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84)
                    .padding(6)
                    .offset(x: -58, y: 14)
                    .opacity(isTyping ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isTyping)
                    .allowsHitTesting(false)
            }
    }

    // MARK: - Speech (bottom)

    private func speechPanel(speaker: String, text: String, geo: GeometryProxy) -> some View {
        let mia = isMia(speaker)
        let nameBoxY = speechBoxHeight * 0.30

        return Image(mia ? "Mia_dialogue_box" : "Joey_dialogue_box")
            .resizable()
            .aspectRatio(2318.0 / 754.0, contentMode: .fit)
            .frame(maxWidth: geo.size.width * 0.78)
            .background(
                GeometryReader { g in
                    Color.clear
                        .onAppear { speechBoxHeight = g.size.height }
                        .onChange(of: g.size.height) { _, h in speechBoxHeight = h }
                }
            )
            .overlay {
                dialogueText(text, size: 26)
                    .minimumScaleFactor(0.8)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 44)
                    .padding(.top, 58)
                    .padding(.bottom, 10)
            }
            .clipped()
            .overlay(alignment: mia ? .topTrailing : .topLeading) {
                nameBox(speaker, isMia: mia)
                    .padding(mia ? .trailing : .leading, 20)
                    .offset(x: mia ? -40 : 40, y: nameBoxY)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(mia ? "Mia_next_button" : "Joey_next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.trailing, 4)
                    .offset(y: 22)
                    .opacity(isTyping ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isTyping)
                    .allowsHitTesting(false)
            }
    }

    // MARK: - Choices (bottom) — bare option buttons, no surrounding box

    private func choicePanel(options: [DecisionRoute], geo: GeometryProxy) -> some View {
        let mia = isMia(lastSpeaker)
        return VStack(spacing: 12) {
            ForEach(options) { route in
                Button {
                    captureScreen(for: route)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.choose(route)
                    }
                } label: {
                    Image(mia ? "Mia_option_button" : "Joey_option_button")
                        .resizable()
                        .aspectRatio(899.0 / 248.0, contentMode: .fit)
                        .frame(maxWidth: geo.size.width * 0.42)
                        .overlay {
                            dialogueText(route.choiceText, size: 24, color: .white)
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                        }
                        .clipped()
                }
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Ending (bottom)

    private func endingPanel(emotion: String) -> some View {
        VStack(spacing: 14) {
            Text("— The End —")
                .font(.custom("FredokaOne-Regular", size: 30))
                .foregroundStyle(.black)

            Text("Mia feels: \(emotion)")
                .font(.custom("Playpen Sans", size: 22))
                .foregroundStyle(.black.opacity(0.7))

            Button("Done") { dismissSelf() }
                .font(.custom("FredokaOne-Regular", size: 22))
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
                .frame(width: 200)

            Text(speaker.uppercased())
                .font(.custom("FredokaOne-Regular", size: 26))
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
