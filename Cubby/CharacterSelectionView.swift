//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct CharacterSelectionView: View {
    var body: some View {
        ZStack() {
            Image("Primary-BG-CharacterSelection-Image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Image("Secondary-BG-CharacterSelection-Image")
                .resizable()
                .scaleEffect(0.98)
                .rotationEffect(.degrees(4))
                .offset(y: -45)
            Text("Character Selection")
                .font(.custom("FreckleFace-Regular", size: 64))
                .foregroundColor(.white)
                .frame(width: 760, height:120, alignment: .center)
                .background(
                    Rectangle()
                        .fill(Color(red: 2/255, green: 64/255, blue: 35/255))
                )
                .offset(x: -50, y: -390)
                .rotationEffect(.degrees(10))

                
//            VStack(){
//                Text("Learn\nBoundaries!")
//
//                    .font(.custom("FreckleFace-Regular", size: 128))
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.white)
//                
//                Button("Play") {
//                }
//                .font(.custom("Slackey-Regular", size: 48))
//                .foregroundColor(Color(red: 255/255, green: 141/255, blue: 40/255))
//                .padding(.horizontal, 120)
//                .padding(.vertical, 24)
//                .background(.white.opacity(0.65), in: Capsule())
//                
//            }
        }
    }
}
    

#Preview {
    CharacterSelectionView()
    }
