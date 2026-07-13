//
//  AudioManager.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import AVFoundation
import UIKit

final class AudioManager {

    private var bgmPlayer: AVAudioPlayer?
    private var ambiencePlayer: AVAudioPlayer?
    private var sfxFootstep: AVAudioPlayer?
    private var sfxInteract: AVAudioPlayer?
    private var sfxJoystick: AVAudioPlayer?
    private var sfxGlow: AVAudioPlayer?

    private let bgmTargetVolume: Float = 0.35
    private let ambienceTargetVolume: Float = 0.45

    private var footstepTimer: TimeInterval = 0
    private var wasInRange = false

    init() {
        bgmPlayer = load("bgm_gameplay_playground_loop_1")
        bgmPlayer?.numberOfLoops = -1
        bgmPlayer?.volume = bgmTargetVolume

        ambiencePlayer = load("amb_playground_day_loop_1")
        ambiencePlayer?.numberOfLoops = -1
        ambiencePlayer?.volume = ambienceTargetVolume

        sfxFootstep = load("sfx_footstep_grass_soft_1")
        sfxInteract = load("sfx_interact_tap_1")
        sfxJoystick = load("sfx_joystick_drag_soft_1")
        sfxGlow = load("sfx_interact_available_glow_1")
    }

    private func load(_ name: String) -> AVAudioPlayer? {
        guard let asset = NSDataAsset(name: name),
              let player = try? AVAudioPlayer(data: asset.data) else {
            print("audio: couldn't load \(name)")
            return nil
        }
        player.prepareToPlay()
        return player
    }

    func startLoop() {
        guard let bgm = bgmPlayer, let amb = ambiencePlayer else { return }
        let startTime = bgm.deviceCurrentTime + 0.05
        bgm.play(atTime: startTime)
        amb.play(atTime: startTime)
    }

    func stopLoop() {
        bgmPlayer?.stop()
        ambiencePlayer?.stop()
    }

    func fadeOut(duration: TimeInterval = 0.3) {
        bgmPlayer?.setVolume(0, fadeDuration: duration)
        ambiencePlayer?.setVolume(0, fadeDuration: duration)
    }

    func fadeIn(duration: TimeInterval = 0.5) {
        bgmPlayer?.setVolume(bgmTargetVolume, fadeDuration: duration)
        ambiencePlayer?.setVolume(ambienceTargetVolume, fadeDuration: duration)
    }

    func tick(dt: TimeInterval, anim: CharacterAnim, isNPCInRange: Bool) {
        if anim == .walking {
            footstepTimer += dt
            if footstepTimer >= 0.45 {
                sfxFootstep?.currentTime = 0
                sfxFootstep?.play()
                footstepTimer = 0
            }
        } else {
            footstepTimer = 0
        }

        if isNPCInRange && !wasInRange {
            sfxGlow?.currentTime = 0
            sfxGlow?.play()
        }
        wasInRange = isNPCInRange
    }

    func playInteract() {
        sfxInteract?.currentTime = 0
        sfxInteract?.play()
    }

    func playJoystickStart() {
        sfxJoystick?.currentTime = 0
        sfxJoystick?.play()
    }
}
