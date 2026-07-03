//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI

struct LandingPageView: View {
    var body: some View {
        ZStack() {
            Image("Primary-BG-LandingPage-Image")
            VStack(){
                Text("Learn\nBoundaries!")

                    .font(.custom("FreckleFace-Regular", size: 128))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Button("Play") {
                }
                .font(.custom("Slackey-Regular", size: 48))
                .foregroundColor(Color(red: 255/255, green: 141/255, blue: 40/255))
                .padding(.horizontal, 120)
                .padding(.vertical, 24)
                .background(.white.opacity(0.65), in: Capsule())
                
            }
        }
    }
}
    

#Preview {
    LandingPageView()
    }
