//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import SwiftUIJoystick

struct ContentView: View {

    @StateObject private var joystickMonitor = JoystickMonitor()
    private let joystickSize: CGFloat = 120

    var body: some View {
        
        ZStack {
            Image("GPBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    JoystickBuilder(
                        monitor: joystickMonitor,
                        width: joystickSize,
                        shape: .circle,
                        background: {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                )
                        },
                        foreground: {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        },
                        locksInPlace: false
                    )
                    .padding(.leading, 32)
                    .padding(.bottom, 24)

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
