//
//  StorybookView.swift
//  Cubby
//
//  Created by Vigo Alexander Sie on 10/07/26.
//

import SwiftUI

struct SituationPageView: View {
    let page: StorybookPage

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("PaperTexture")
                    .resizable()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: geo.size.height * 0.03) {
                    Text("Bagaimana situasinya?")
                        .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.024))
                    if let before = page.sections.first {
                        Text(before.body ?? "")
                            .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.017))
                    }
                    Spacer()
                }
                .padding(geo.size.width * 0.04)
            }
        }
    }
}

struct OutcomePageView: View {
    let page: StorybookPage

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("PaperTexture")
                    .resizable()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: geo.size.height * 0.03) {
                        ForEach(page.sections.dropFirst(), id: \.self) { section in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(section.heading)
                                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.022))
                                if let body = section.body {
                                    Text(body)
                                        .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.017))
                                }
                                if let questions = section.questions {
                                    ForEach(questions, id: \.self) { q in
                                        Text("•  \(q)")
                                            .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.017))
                                    }
                                }
                            }
                        }
                    }
                    .padding(geo.size.width * 0.04)
                }
            }
        }
    }
}
