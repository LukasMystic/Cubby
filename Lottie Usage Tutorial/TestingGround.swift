//
//  TestingGround.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 08/07/26.
//  GitHub Repository: https://github.com/airbnb/lottie-spm.git
//  Must use .JSON file for tutorial
//  Documentation how to use is available in this file

import SwiftUI
import Lottie

struct ContentView: View {
  var body: some View {
    ZStack {
        LottieView(animation: .named("MiaAnimation"))
            .playing(loopMode: .loop)
            .frame(width: 300, height: 300)
            .offset(x: -140)
        
        LottieView(animation: .named("JoeyAnimation"))
            .playing(loopMode: .loop)
            .frame(width: 300, height: 300)
            .offset(x: 140)
    }
  }
}

#Preview {
    ContentView()
}
