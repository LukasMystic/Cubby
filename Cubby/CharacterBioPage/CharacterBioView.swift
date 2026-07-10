//
//  CharacterBioView.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

import SwiftUI

struct CharacterBioView: View {
    @State private var viewModel: CharacterBioViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(selectedCharacter: String) {
        _viewModel = State(wrappedValue: CharacterBioViewModel(selectedCharacter: selectedCharacter))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Secondary-BG-CharacterSelection-Image")
                    .scaleEffect(1.5)
                
                HStack {
                    Image(viewModel.character.imageName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.65)
                        .offset(x: -geo.size.width * 0.015)
                    Image("Primary-PlaceHolder-CharacterBio-Image")
                        .offset(x: -geo.size.width * 0.073)
                }
                
                Text(viewModel.character.bioText)
                    .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.023))
                    .lineSpacing(10)
                    .offset(x: geo.size.width * 0.242)
                    .frame(width: geo.size.width * 0.22)
                
                Rectangle()
                    .frame(width: geo.size.width * 0.586, height: geo.size.height * 0.146)
                    .offset(y: -geo.size.height * 0.342)
                    .rotationEffect(.degrees(2.64))
                    .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
                
                Text("Halo Aku, \(viewModel.character.name)!")
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.047))
                    .foregroundColor(.white)
                    .offset(y: -geo.size.height * 0.342)
                    .rotationEffect(.degrees(2.64))
                
                Button("Play") {
                    viewModel.playTapped()
                }
                .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
                .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.035))
                .padding(.horizontal, geo.size.width * 0.088)
                .padding(.vertical, geo.size.height * 0.023)
                .background(.white.opacity(0.90), in: Capsule())
                .contentShape(Capsule())
                .buttonStyle(.plain)
                .offset(x: geo.size.width * 0.293, y: geo.size.height * 0.342)
                .rotationEffect(.degrees(-3))
                .accessibilityLabel("Play Button")
                
                Button("<") {
                    dismiss()
                }
                .foregroundColor(.black)
                .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.035))
                .padding(geo.size.width * 0.026)
                .background(Color(red: 242/255, green: 176/255, blue: 85/255), in: Circle())
                .contentShape(Circle())
                .buttonStyle(.plain)
                .offset(x: -geo.size.width * 0.366, y: -geo.size.height * 0.391)
                .accessibilityLabel("Back Button")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CharacterSelectionView()
}
