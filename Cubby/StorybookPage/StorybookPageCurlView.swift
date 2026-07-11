//
//  Storybook/StorybookPageCurlView.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 10/07/26.
//

import SwiftUI
import UIKit

private class StorybookFaceHostingController: UIHostingController<AnyView> {
    var faceIndex: Int = 0
}

struct StorybookPageCurlView: UIViewControllerRepresentable {
    var viewModel: StorybookViewModel
    
    private func totalFaces() -> Int { viewModel.pages.count * 2 }
    
    private func view(forFace index: Int) -> AnyView? {
        let pageIndex = index / 2
        guard viewModel.pages.indices.contains(pageIndex) else { return nil }
        let page = viewModel.pages[pageIndex]
        return index % 2 == 0
        ? AnyView(SituationPageView(page: page))
        : AnyView(OutcomePageView(page: page))
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [.spineLocation: UIPageViewController.SpineLocation.mid.rawValue]
        )
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator
        pvc.isDoubleSided = true
        
        let startFace = viewModel.currentPageIndex * 2
        if let left = context.coordinator.controller(at: startFace),
           let right = context.coordinator.controller(at: startFace + 1) {
            pvc.setViewControllers([left, right], direction: .forward, animated: false)
        }
        return pvc
    }
    
    func updateUIViewController(_ pvc: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        
        guard let currentLeft = pvc.viewControllers?.first as? StorybookFaceHostingController else { return }
        let expectedFace = viewModel.currentPageIndex * 2
        guard currentLeft.faceIndex != expectedFace else { return }
        
        guard let left = context.coordinator.controller(at: expectedFace),
              let right = context.coordinator.controller(at: expectedFace + 1) else { return }
        let direction: UIPageViewController.NavigationDirection =
        expectedFace > currentLeft.faceIndex ? .forward : .reverse
        pvc.setViewControllers([left, right], direction: direction, animated: true)
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: StorybookPageCurlView
        init(_ parent: StorybookPageCurlView) { self.parent = parent }
        
        fileprivate func controller(at faceIndex: Int) -> StorybookFaceHostingController? {
            guard faceIndex >= 0, faceIndex < parent.totalFaces(),
                  let content = parent.view(forFace: faceIndex) else { return nil }
            let host = StorybookFaceHostingController(rootView: content)
            host.faceIndex = faceIndex
            return host
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? StorybookFaceHostingController else { return nil }
            return controller(at: vc.faceIndex - 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let vc = viewController as? StorybookFaceHostingController else { return nil }
            return controller(at: vc.faceIndex + 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let leftVC = pageViewController.viewControllers?.first as? StorybookFaceHostingController else { return }
            parent.viewModel.currentPageIndex = leftVC.faceIndex / 2
        }
    }
}
