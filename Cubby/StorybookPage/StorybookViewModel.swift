// Storybook/StorybookViewModel.swift

import Foundation
import UIKit

@Observable
class StorybookViewModel {
    var pages: [StorybookPage]
    var currentPageIndex: Int = 0

    init(pages: [StorybookPage] = []) {
        self.pages = pages
    }

    static func fromUserProgress() -> StorybookViewModel {
        guard let progress = UserProgressLoader.loadProgress() else {
            return StorybookViewModel(pages: [])
        }

        let router: StoryRouter? = loadJSON("main")

        let orderedBranchNames = progress.decisions
            .sorted { $0.key < $1.key }
            .compactMap { (decisionId, option) -> String? in
                router?.decisions
                    .first(where: { $0.decisionId == decisionId })?
                    .routes
                    .first(where: { $0.option == option })?
                    .targetFile
                    .replacingOccurrences(of: ".json", with: "")
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
}
