//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct LandingPageView: View {
    @State private var viewModel = LandingPageViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Primary-BG-LandingPage-Image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 400){
                    Image("Primary-Text-LandingPage-Image")
                    Button("Play") {
                        viewModel.onPlayButtonTapped()
                    }
                    .font(.custom("FredokaOne-Regular", size: 48))
                    .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
                    .padding(.horizontal, 120)
                    .padding(.vertical, 24)
                    .background(.white.opacity(0.65), in: Capsule())
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Play Button")
                }
            }
            .navigationDestination(isPresented: $viewModel.goToCharacterSelection) {
//                CharacterSelectionPageView()
            }
        }
    }
}

#Preview {
    LandingPageView()
}
