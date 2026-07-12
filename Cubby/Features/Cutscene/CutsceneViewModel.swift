//
//  CutsceneViewModel.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 02/07/26.
//

import SwiftUI
import Observation

@Observable
final class CutsceneViewModel {

    struct Panel {
        let text: String
        let miaAsset: String?
        let joeyAsset: String?
    }

    let panels: [Panel] = [
        Panel(text: "It's a sunny afternoon at the playground...",
              miaAsset: nil,                   joeyAsset: nil),
        Panel(text: "Mia found a quiet spot and started building a tower with the blocks.",
              miaAsset: "EX_Mia_001_Neutral",  joeyAsset: nil),
        Panel(text: "You spot her from across the playground and run over, excited to play!",
              miaAsset: "EX_Mia_001_Neutral",  joeyAsset: "EX_Joey_003_Excited")
    ]

    private(set) var panelIndex: Int = 0
    private(set) var displayedText: String = ""
    private(set) var showBackground: Bool = false
    private(set) var showMia: Bool = false
    private(set) var showJoey: Bool = false
    private(set) var showGame: Bool = false
    private(set) var screenFlash: Double = 1

    private var sequenceTask: Task<Void, Never>?

    func startSequence() {
        sequenceTask = Task { await runCutscene() }
    }

    func skip() {
        sequenceTask?.cancel()
        withAnimation(.easeInOut(duration: 0.4)) { showGame = true }
    }

    // MARK: - Sequence

    @MainActor
    private func runCutscene() async {
        // Fade in the background while still covered by the opening white flash
        withAnimation(.easeIn(duration: 0.5)) { showBackground = true }
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !Task.isCancelled else { return }

        // Reveal scene: fade flash to 0, exposing the fully-loaded background
        withAnimation(.easeOut(duration: 0.7)) { screenFlash = 0 }
        try? await Task.sleep(nanoseconds: 800_000_000)
        guard !Task.isCancelled else { return }

        // Panel 0: establishing shot — playground, no characters yet
        await typewrite(panels[0].text)
        guard !Task.isCancelled else { return }
        try? await Task.sleep(nanoseconds: 3_500_000_000)
        guard !Task.isCancelled else { return }

        // Flash → Panel 1: Mia slides in after flash clears
        await flashPanel(newIndex: 1, revealMia: true)
        guard !Task.isCancelled else { return }
        await typewrite(panels[1].text)
        guard !Task.isCancelled else { return }
        try? await Task.sleep(nanoseconds: 4_500_000_000)
        guard !Task.isCancelled else { return }

        // Flash → Panel 2: Joey slides in after flash clears
        await flashPanel(newIndex: 2, revealJoey: true)
        guard !Task.isCancelled else { return }
        await typewrite(panels[2].text)
        guard !Task.isCancelled else { return }
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        guard !Task.isCancelled else { return }

        // All done — transition to the game
        withAnimation(.easeInOut(duration: 0.4)) { showGame = true }
    }

    // Flashes white to mask the scene change, then reveals new characters on a clean screen.
    @MainActor
    private func flashPanel(newIndex: Int, revealMia: Bool = false, revealJoey: Bool = false) async {
        displayedText = ""
        withAnimation(.easeIn(duration: 0.18)) { screenFlash = 1 }
        try? await Task.sleep(nanoseconds: 200_000_000)
        guard !Task.isCancelled else { return }

        panelIndex = newIndex

        withAnimation(.easeOut(duration: 0.30)) { screenFlash = 0 }
        try? await Task.sleep(nanoseconds: 350_000_000)
        guard !Task.isCancelled else { return }

        if revealMia  { withAnimation { showMia  = true } }
        if revealJoey { withAnimation { showJoey = true } }

        try? await Task.sleep(nanoseconds: 400_000_000)
        guard !Task.isCancelled else { return }
    }

    @MainActor
    private func typewrite(_ text: String) async {
        displayedText = ""
        for char in text {
            guard !Task.isCancelled else { return }
            displayedText.append(char)
            try? await Task.sleep(nanoseconds: 30_000_000)
        }
    }
}
