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
        ZStack {
            Image("Secondary-BG-CharacterSelection-Image")
                .scaleEffect(1.5)
            HStack(){
                Image(viewModel.character.imageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.65)
                    .offset(x: -20)
                Image("Primary-PlaceHolder-CharacterBio-Image")
                    .offset(x: -100)
            }
            
            Text(viewModel.character.bioText)
                .font(.custom("PlaypenSans-Regular",size: 32))
                .lineSpacing(10)
                .offset(x: 330)
                .frame(width: 300)
            
            Rectangle()
                .frame(width: 800, height: 150)
                .offset(y: -350)
                .rotationEffect(.degrees(2.64))
                .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
            Text("Halo Aku, \(viewModel.character.name)!")
                .font(.custom("FredokaOne-Regular", size: 64))
                .foregroundColor(.white)
                .offset(y: -350)
                .rotationEffect(.degrees(2.64))
            Button("Play") {
                viewModel.playTapped()
            }
            .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
            .font(.custom("FredokaOne-Regular", size: 48))
            .padding(.horizontal, 120)
            .padding(.vertical, 24)
            .contentShape(Capsule())
            .background(.white.opacity(0.90), in: Capsule())
            .offset(x: 400, y: 350)
            .rotationEffect(.degrees(-3))
            .accessibilityLabel("Play Button")
                
            Button("<") {
                dismiss()
            }
            .foregroundColor(Color(.black))
            .font(.custom("FredokaOne-Regular", size: 48))
            .padding(36)
            .contentShape(Circle())
            .background(Color(red: 242/255, green: 176/255, blue: 85/255), in: Circle())
            .offset(x: -500, y: -400)
            .accessibilityLabel("Back Button")
            
                
        }
        .navigationBarBackButtonHidden(true)
        
//        .navigationDestination(isPresented: $viewModel.navigateToGame) {
//            GameView(selectedCharacter: viewModel.character.id)
//        }
    }
}

#Preview {
    CharacterSelectionView()
    }
