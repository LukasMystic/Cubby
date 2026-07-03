//
//  ContentView.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import SpriteKit
import SwiftUIJoystick

struct GameView: View {

    @StateObject private var joystickMonitor = JoystickMonitor()

    // Stable scene reference connected via onAppear
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()

    private let joystickSize: CGFloat = 150

    var body: some View {
        ZStack {

            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.joystickMonitor = joystickMonitor
                }

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
                                        .stroke(Color.white.opacity(0.45), lineWidth: 2.5)
                                )
                        },
                        foreground: {
                            Circle()
                                .fill(Color.white.opacity(0.75))
                                .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                        },
                        locksInPlace: false
                    )
                    .padding(.leading, 32)
                    .padding(.bottom, 28)

                    Spacer()

                    Button(action: {
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.45), lineWidth: 2.5)
                                )
                                .frame(width: joystickSize, height: joystickSize)

                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 44, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                    .padding(.trailing, 32)
                    .padding(.bottom, 28)
                }
            }
        }
    }
}

#Preview {
   GameView()
}
