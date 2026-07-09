//
//  CharacterBioView.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 05/07/26.
//

import SwiftUI

struct CharacterBioView: View {
    @StateObject private var viewModel: CharacterBioViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(selectedCharacter: String) {
        _viewModel = StateObject(wrappedValue: CharacterBioViewModel(selectedCharacter: selectedCharacter))
    }
    
    var body: some View {
        VStack {
            Image(viewModel.character.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text(viewModel.character.name)
                .font(.title)
            
            Text(viewModel.character.bioText)
            
            HStack {
                Button("Back") {
                    dismiss()
                }
                
                Button("Play") {
                    viewModel.playTapped()
                }
            }
        }
//        .navigationDestination(isPresented: $viewModel.navigateToGame) {
//            GameView(selectedCharacter: viewModel.character.id)
//        }
    }
}
