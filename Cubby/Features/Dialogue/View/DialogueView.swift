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

    var body: some View {
        ZStack {
            Image("Cubby_Gameplay_Page_01_BG 1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.25).ignoresSafeArea()

            VStack(spacing: 0) {
                characters
                bottomPanel
            }
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(20)
            }
        }
    }

    // player on the left, NPC on the right
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

    // linear dialogue and multiple-choice
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

    // Narrator
    private func narrativePanel(text: String) -> some View {
        HStack {
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }

    // Character dialogue
    private func speechPanel(speaker: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(speaker)
                .font(.subheadline.bold())
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Color.yellow.opacity(0.9))
                .clipShape(Capsule())

            HStack(alignment: .bottom) {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }

    // capture the screen right now and hand it to the viewmodel to save
    private func captureScreen(for route: DecisionRoute) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        let img = renderer.image { _ in window.drawHierarchy(in: window.bounds, afterScreenUpdates: false) }
        viewModel.saveDecisionScreenshot(img, targetFile: route.targetFile)
    }

    // Multiple choice
    private func choicePanel(options: [DecisionRoute]) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(options) { route in
                Button {
                    captureScreen(for: route)
                    viewModel.choose(route)
                } label: {
                    Text(route.choiceText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }

    // when story ends
    private func endingPanel(emotion: String) -> some View {
        VStack(spacing: 14) {
            Text("— The End —")
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text("Mia feels: \(emotion)")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Done") { dismiss() }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 11)
                .background(Color.accentColor)
                .clipShape(Capsule())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }
}

#Preview {
    DialogueView()
}
