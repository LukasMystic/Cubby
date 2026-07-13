// Storybook/StorybookViewModel.swift

import Foundation
import UIKit
import AVFoundation

@Observable
class StorybookViewModel {
    var pages: [StorybookPage]
    var currentPageIndex: Int = 0
    private var audioPlayer: AVAudioPlayer?

    init(pages: [StorybookPage] = []) {
        self.pages = pages
    }

    static func fromUserProgress() -> StorybookViewModel {
        guard let progress = UserProgressLoader.loadProgress() else {
            return StorybookViewModel(pages: [])
        }

        let router: StoryRouter? = loadJSON("main")
        let sortedDecisions = progress.decisions.sorted { $0.key < $1.key }

        var orderedBranchNames: [String] = []
        for (decisionId, option) in sortedDecisions {
            guard let decision = router?.decisions.first(where: { $0.decisionId == decisionId }) else { continue }
            guard let route = decision.routes.first(where: { $0.option == option }) else { continue }
            let branchName = route.targetFile.replacingOccurrences(of: ".json", with: "")
            orderedBranchNames.append(branchName)
        }

        let pages: [StorybookPage] = orderedBranchNames.compactMap { branchName in
            let branch: BranchFile? = loadJSON(branchName)
            return branch?.storybookPage
        }

        return StorybookViewModel(pages: pages)
    }

    private static func loadJSON<T: Decodable>(_ fileName: String) -> T? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let result = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return result
    }

    func screenshot(for page: StorybookPage) -> UIImage? {
        let branchName = page.sourceFile.replacingOccurrences(of: ".json", with: "")
        return UserProgressLoader.loadScreenshot(branchName: branchName)
    }
    
    func clearScreenshots() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: docsDir, includingPropertiesForKeys: nil
        ) else { return }

        for url in urls where url.pathExtension == "png" {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func clearUserProgress() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docsDir.appendingPathComponent("userProgress.json")
        let empty = UserProgress()
        if let data = try? JSONEncoder().encode(empty) {
            try? data.write(to: url, options: .atomic)
        }
    }

    var currentPage: StorybookPage? {
        pages.indices.contains(currentPageIndex) ? pages[currentPageIndex] : nil
    }

    var isFirstPage: Bool { currentPageIndex == 0 }
    var isLastPage: Bool { currentPageIndex >= pages.count - 1 }

    func goToNext() {
        guard !isLastPage else { return }
        currentPageIndex += 1
    }

    func goToPrevious() {
        guard !isFirstPage else { return }
        currentPageIndex -= 1
    }
    
    func playBackgroundMusic(named fileName: String = "raw_bgm_bgm_storybook_reflection_loop_1", fileExtension: String = "wav") {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
                print("couldn't find \(fileName).\(fileExtension)")
                return
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1   // loop forever
                audioPlayer?.volume = 0.4
                audioPlayer?.play()
            } catch {
                print("couldn't play storybook music: \(error)")
            }
        }

        func stopBackgroundMusic() {
            audioPlayer?.stop()
        }
}
