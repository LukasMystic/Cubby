//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct CharacterSelectionView: View {
    @StateObject private var viewModel = CharacterSelectionViewModel()
    
    var body: some View {
        NavigationStack{
            HStack(spacing: 200) {
                ForEach(Array(Character.all.values), id: \.id) { character in
                    Image(character.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                        .onTapGesture {
                            viewModel.selectCharacter(character.id)
                        }
                }
            }
            .navigationDestination(item: $viewModel.selectedCharacter) { character in
                CharacterBioView(selectedCharacter: character)
            }
        }
    }
}
    

    

#Preview {
    CharacterSelectionView()
    }
