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
        ZStack {
            Image("GPBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 80) {
                Text("Well done! You finished!")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.11, green: 0.25, blue: 0.09))
                    .multilineTextAlignment(.center)

                HStack(spacing: 40) {
                    closingButton("Back to\nplayground", action: onBackToPlayground)
                    closingButton("Try again", action: onTryAgain)
                }
            }
            .padding(.horizontal, 60)
        }
    }

    private func closingButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.82, green: 0.42, blue: 0.11))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.vertical, 40)
                .frame(minWidth: 320, minHeight: 150)
                .background(
                    Image("option_conversation_box").resizable()
                )
        }
    }
}

#Preview {
    ClosingView()
}
