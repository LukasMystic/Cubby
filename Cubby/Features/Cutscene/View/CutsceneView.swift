//
//  CutsceneView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct CutsceneView: View {

    @State private var viewModel = CutsceneViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                sceneLayer(geo: geo)

                Color.white
                    .opacity(viewModel.screenFlash)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .zIndex(1)

                if viewModel.showGame {
                    GameView()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { viewModel.startSequence() }
    }

    private func sceneLayer(geo: GeometryProxy) -> some View {
        ZStack {
            Image("Cubby_Gameplay_NoCharacter 1")
                .resizable()
                .scaledToFill()
                .blur(radius: 8, opaque: true)
                .ignoresSafeArea()
                .opacity(viewModel.showBackground ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: viewModel.showBackground)

            characters(geo: geo)
        }
        .overlay(alignment: .top) {
            narrationBox(geo: geo)
                .padding(.horizontal, 24)
                .padding(.top, geo.size.height * 0.13)
        }
        .overlay(alignment: .topTrailing) {
            skipButton(geo: geo)
        }
    }

    private func characters(geo: GeometryProxy) -> some View {
        let charH = geo.size.height * 0.70
        let charFrameH = charH * 0.76
        let charPad = charH * 0.0975
        let sidePad = 20 + charH * 0.20

        return HStack(alignment: .bottom, spacing: 0) {
            characterSlot(
                asset: viewModel.panels[viewModel.panelIndex].miaAsset,
                frameH: charFrameH, bottomPad: charPad,
                visible: viewModel.showMia, slideOffset: -60
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, sidePad)

            characterSlot(
                asset: viewModel.panels[viewModel.panelIndex].joeyAsset,
                frameH: charFrameH, bottomPad: charPad,
                visible: viewModel.showJoey, slideOffset: 60
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, sidePad)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func characterSlot(asset: String?, frameH: CGFloat, bottomPad: CGFloat, visible: Bool, slideOffset: CGFloat) -> some View {
        if let asset {
            Image(asset)
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(height: frameH)
                .padding(.bottom, bottomPad)
                .opacity(visible ? 1 : 0)
                .offset(x: visible ? 0 : slideOffset)
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: visible)
        } else {
            Color.clear.frame(height: frameH)
        }
    }

    private func narrationBox(geo: GeometryProxy) -> some View {
        Image("Narration_box")
            .resizable()
            .aspectRatio(1711.0 / 410.0, contentMode: .fit)
            .frame(maxWidth: geo.size.width * 0.75)
            .overlay {
                Text(viewModel.displayedText)
                    .font(.custom("Playpen Sans", size: geo.size.height * 0.030))
                    .foregroundStyle(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(3)
                    .padding(.horizontal, 52)
                    .padding(.vertical, 10)
            }
    }
    
    private func skipButton(geo: GeometryProxy) -> some View {
        Button { viewModel.skip() } label: {
            Image("Joey_option_button")
                .resizable()
                .aspectRatio(899.0 / 248.0, contentMode: .fit)
                .frame(width: geo.size.width * 0.15)
                .overlay {
                    Text("Skip")
                        .font(.custom("FredokaOne-Regular", size: geo.size.height * 0.032))
                        .foregroundStyle(.white)
                }
        }
        .padding(24)
        .offset(x: -16, y: 24)
    }
}

#Preview(traits: .landscapeLeft) {
    CutsceneView()
}
