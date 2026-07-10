//
//  StorybookViewModel.swift
//  Cubby
//

// Storybook/StorybookViewModel.swift

import Foundation

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

        let orderedBranches = progress.decisions
            .sorted { $0.key < $1.key }
            .map { $0.value }

        let pages: [StorybookPage] = orderedBranches.compactMap { branchName in
            guard let url = Bundle.main.url(forResource: branchName, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let branch = try? JSONDecoder().decode(BranchFile.self, from: data) else {
                return nil
            }
            return branch.storybookPage
        }

        return StorybookViewModel(pages: pages)
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
