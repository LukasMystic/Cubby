//
//  DialogueView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import UIKit

struct DialogueView: View {
    var onDismiss: (() -> Void)? = nil
    var onStoryEnd: (() -> Void)? = nil

    @State private var viewModel = DialogueViewModel()
    @Environment(\.dismiss) private var envDismiss
    @State private var lastSpeaker = ""
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
        case .choice: return "Joey"
        default: return nil
        }
    }

    private var panelAlignment: Alignment {
        switch viewModel.currentBeat {
        case .narrative: return .top
        case .choice:return .center
        default:return .bottom
        }
    }

    private var currentBeatText: String {
        switch viewModel.currentBeat {
        case .narrative(let text): return text
        case .speech(_, let text): return text
        default: return ""
        }
    }

    private var backgroundDim: Double {
        switch viewModel.currentBeat {
        case .speech, .choice: return 0.7
        default: return 0
        }
    }

    private func dismissSelf() {
        viewModel.audioManager.onBack()
        if let onDismiss { onDismiss() } else { envDismiss() }
    }

    private func handleAdvance() {
        guard !isTyping else { return }
        viewModel.audioManager.onNext()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.advance()
        }
    }

    // Body
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Cubby_Gameplay_NoCharacter 1")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 8, opaque: true)
                    .ignoresSafeArea()

                Color.black
                    .opacity(backgroundDim)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: backgroundDim)

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
                    try? await Task.sleep(nanoseconds: 30_000_000)
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
        }
        .ignoresSafeArea()
    }

    // Characters
    private func characters(geo: GeometryProxy) -> some View {
        let active  = activeSpeaker
        // height
        let charH   = geo.size.height * 0.70
        let miaDim  = active.map { isMia($0) ?  0.0 : -0.35 } ?? 0
        let joeyDim = active.map { isMia($0) ? -0.35 :  0.0 } ?? 0
        let hasMiaExpr  = !viewModel.miaExpressionKey.isEmpty
        let hasJoeyExpr = !viewModel.joeyExpressionKey.isEmpty

        let charFrameH: CGFloat  = charH * 0.76
        let charExtraPad: CGFloat = charH * 0.0975

        let miaLeadPad: CGFloat   = hasMiaExpr  ? 20 + charH * 0.08 : 20
        let joeyTrailPad: CGFloat = hasJoeyExpr ? 20 + charH * 0.08 : 60

        // during a choice, pull both characters out to the edges so the option boxes have room
        let isChoice: Bool
        if case .choice = viewModel.currentBeat { isChoice = true } else { isChoice = false }
        let miaPos: CharacterPosition  = isChoice ? .far : viewModel.miaPosition
        let joeyPos: CharacterPosition = isChoice ? .far : viewModel.joeyPosition

        let miaShift  = positionShift(miaPos, width: geo.size.width)
        let joeyShift = positionShift(joeyPos, width: geo.size.width)

        return HStack(alignment: .bottom, spacing: 0) {
            Image(hasMiaExpr ? viewModel.miaAssetName : "mia_1 2")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(height: hasMiaExpr ? charFrameH : charH)
                .padding(.bottom, hasMiaExpr ? charExtraPad : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, miaLeadPad)
                .offset(x: miaShift)
                .brightness(miaDim)
                .animation(.easeInOut(duration: 0.3), value: miaDim)
                .animation(.easeInOut(duration: 0.4), value: viewModel.miaAssetName)
                .animation(.easeInOut(duration: 0.6), value: miaPos)

            Image(hasJoeyExpr ? viewModel.joeyAssetName : "joey 3")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(height: hasJoeyExpr ? charFrameH : charH)
                .padding(.bottom, hasJoeyExpr ? charExtraPad : 0)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, joeyTrailPad)
                .offset(x: -joeyShift)
                .brightness(joeyDim)
                .animation(.easeInOut(duration: 0.3), value: joeyDim)
                .animation(.easeInOut(duration: 0.4), value: viewModel.joeyAssetName)
                .animation(.easeInOut(duration: 0.6), value: joeyPos)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .offset(y: panelAlignment == .bottom ? -geo.size.height * 0.08 : 0)
    }

    // how far toward center a character slides for a given position
    private func positionShift(_ pos: CharacterPosition, width: CGFloat) -> CGFloat {
        switch pos {
        case .far:   return 0
        case .mid:   return width * 0.12
        case .close: return width * 0.24
        }
    }

    // Panels
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

    // Narrative (top)
    private func narrativePanel(text: String, geo: GeometryProxy) -> some View {
        Image("Narration_box")
            .resizable()
            .aspectRatio(1711.0 / 410.0, contentMode: .fit)
            .frame(maxWidth: geo.size.width * 0.75)
            .overlay {
                dialogueText(text, size: geo.size.height * 0.030)
                    .minimumScaleFactor(0.6)
                    .lineLimit(3)
                    .padding(.horizontal, 52)
                    .padding(.vertical, 10)
            }
            .overlay(alignment: .bottomTrailing) {
                Image("Next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.073)
                    .padding(6)
                    .offset(x: -geo.size.width * 0.049, y: geo.size.height * 0.016)
                    .opacity(isTyping ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isTyping)
                    .allowsHitTesting(false)
            }
    }

    // Speech (bottom)
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
                dialogueText(text, size: geo.size.height * 0.032)
                    .minimumScaleFactor(0.7)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 44)
                    .padding(.top, 58)
                    .padding(.bottom, 10)
            }
            .clipped()
            .overlay(alignment: mia ? .topTrailing : .topLeading) {
                nameBox(speaker, isMia: mia, geo: geo)
                    .padding(mia ? .trailing : .leading, 20)
                    .offset(x: mia ? -40 : 40, y: nameBoxY)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(mia ? "Mia_next_button" : "Joey_next_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.085)
                    .padding(.trailing, 4)
                    .offset(y: geo.size.height * 0.026)
                    .opacity(isTyping ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isTyping)
                    .allowsHitTesting(false)
            }
    }

    // Choices (bottom)
    private func choicePanel(options: [DecisionRoute], geo: GeometryProxy) -> some View {
        return VStack(spacing: 12) {
            ForEach(options) { route in
                Button {
                    viewModel.audioManager.onChoiceTap()
                    captureScreen(for: route)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.choose(route)
                    }
                } label: {
                    Image("Joey_option_button")
                        .resizable()
                        .aspectRatio(899.0 / 248.0, contentMode: .fit)
                        .frame(maxWidth: geo.size.width * 0.42)
                        .overlay {
                            dialogueText(route.choiceText, size: geo.size.height * 0.028, color: .white)
                                .minimumScaleFactor(0.6)
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

    // Ending (bottom)
    private func endingPanel(emotion: String) -> some View {
        VStack(spacing: 14) {
            Text("— The End —")
                .font(.custom("FredokaOne-Regular", size: 30))
                .foregroundStyle(.black)

            Text("Mia feels: \(emotion)")
                .font(.custom("Playpen Sans", size: 22))
                .foregroundStyle(.black.opacity(0.7))

            Button("Done") {
                if let onStoryEnd { onStoryEnd() } else { dismissSelf() }
            }
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

    // Shared helpers
    private func dialogueText(_ text: String, size: CGFloat, color: Color = .black.opacity(0.85)) -> some View {
        Text(text)
            .font(.custom("Playpen Sans", size: size))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
    }

    private func nameBox(_ speaker: String, isMia: Bool, geo: GeometryProxy) -> some View {
        ZStack {
            Image(isMia ? "Mia_name_box" : "Joey_name_box")
                .resizable()
                .aspectRatio(520.0 / 150.0, contentMode: .fit)
                .frame(width: geo.size.width * 0.168)

            Text(speaker.uppercased())
                .font(.custom("FredokaOne-Regular", size: geo.size.height * 0.032))
                .foregroundStyle(.white)
        }
    }

    // Screenshot capture
    private func captureScreen(for route: DecisionRoute) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let img = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: false) }
        viewModel.saveDecisionScreenshot(img, targetFile: route.targetFile)
    }
}

#Preview(traits: .landscapeLeft) {
    DialogueView()
}
