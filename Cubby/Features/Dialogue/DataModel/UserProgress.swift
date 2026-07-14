//
//  UserProgress.swift
//  Cubby
//
//  Created by Stanley Pratama Teguh on 07/07/26.
//

import Foundation
import UIKit

struct UserProgress: Codable {
    // decisions maps decision node ID → chosen option key, e.g.:
    //   "dp_001" → "1A"
    //   "dp_002" → "2B"
    var decisions: [String: String] = [:]
}


// ─── FOR THE RESULTS PAGE DEV ────────────────────────────────────────────────
//
// Files are saved to the app's Documents folder:
//   userProgress.json  →  which branch the player chose at each decision point
//   1A.png, 2B.png …  →  screenshot of the dialogue screen when that choice was made
//
// Use the loader below to pull everything in one call.
// ─────────────────────────────────────────────────────────────────────────────


// copy this whole struct into your feature — no other dependencies needed
//
 struct UserProgressLoader {

     // the app's Documents folder — same place the game writes to
     private static var docsDir: URL {
         FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     }

     // load the decision log
     // returns nil if the player hasn't made any choices yet
     static func loadProgress() -> UserProgress? {
         let url = docsDir.appendingPathComponent("userProgress.json")
         guard let data = try? Data(contentsOf: url) else { return nil }
         return try? JSONDecoder().decode(UserProgress.self, from: data)
     }

     // load the screenshot for a specific branch, e.g. branchName = "1A"
     // returns nil if that decision hasn't been made yet
     static func loadScreenshot(branchName: String) -> UIImage? {
         let url = docsDir.appendingPathComponent("\(branchName).png")
         guard let data = try? Data(contentsOf: url) else { return nil }
         return UIImage(data: data)
     }

     // load every saved screenshot at once
     // returns array of (branchName, image) e.g. [("1A", <UIImage>), ("2B", <UIImage>)]
     static func loadAllScreenshots() -> [(branch: String, image: UIImage)] {
         let urls = (try? FileManager.default.contentsOfDirectory(
             at: docsDir,
             includingPropertiesForKeys: nil
         ).filter { $0.pathExtension == "png" }) ?? []

         return urls.compactMap { url in
             guard let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) else { return nil }
             let branch = url.deletingPathExtension().lastPathComponent
             return (branch, image)
         }
     }
 }
//
// ── USAGE EXAMPLE ────────────────────────────────────────────────────────────
//
// if let progress = UserProgressLoader.loadProgress() {
//     print(progress.decisions)  // e.g. ["dp_001": "1A", "dp_002": "2C"]
// }
//
// if let img = UserProgressLoader.loadScreenshot(branchName: "1A") {
//     // show img in an Image view or process it however you need
// }
//
// let all = UserProgressLoader.loadAllScreenshots()
// for (branch, image) in all {
//     print("branch \(branch) → \(image.size)")
// }
//
// ─────────────────────────────────────────────────────────────────────────────
