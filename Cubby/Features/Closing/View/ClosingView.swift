//
//  ClosingView.swift
//  Cubby
//
//  Created by Sayyidah Fatimah Azzahra on 07/07/26.
//

import SwiftUI

struct ClosingView: View {

    var onBackToPlayground: () -> Void = {}
    var onTryAgain: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Cubby_Gameplay_NoCharacter 1")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 8, opaque: true)
                    .ignoresSafeArea()

                VStack(spacing: geo.size.height * 0.08) {
                    Text("Well done! You finished!")
                        .font(.custom("FredokaOne-Regular", size: geo.size.height * 0.06))
                        .foregroundStyle(Color(red: 0.11, green: 0.25, blue: 0.09))
                        .multilineTextAlignment(.center)

                    HStack(spacing: geo.size.width * 0.04) {
                        closingButton("Back to\nplayground", geo: geo, action: onBackToPlayground)
                        closingButton("Try again", geo: geo, action: onTryAgain)
                    }
                }
                .padding(.horizontal, 60)
            }
        }
        .ignoresSafeArea()
    }

    private func closingButton(_ title: String, geo: GeometryProxy, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image("Joey_option_button")
                .resizable()
                .aspectRatio(899.0 / 248.0, contentMode: .fit)
                .frame(maxWidth: geo.size.width * 0.36)
                .overlay {
                    Text(title)
                        .font(.custom("FredokaOne-Regular", size: geo.size.height * 0.032))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 40)
                }
                .clipped()
        }
    }
}

#Preview {
    ClosingView()
}
