//
//  StorybookView.swift
//  Cubby
//

import SwiftUI

struct StorybookView: View {
    var viewModel: StorybookViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Cubby_Gameplay_NoCharacter 1")
                    .resizable()
                    .ignoresSafeArea()
                Color.black.opacity(0.05)
                    .ignoresSafeArea()

                if viewModel.pages.isEmpty {
                    Text("No pages yet").foregroundColor(.gray)
                } else {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 253/255, green: 250/255, blue: 240/255))
                                .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.75)

                            StorybookPageCurlView(viewModel: viewModel)
                                .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.75)
                        }
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)

                        Text("\(viewModel.currentPageIndex + 1) / \(viewModel.pages.count)")
                            .font(.custom("FredokaOne-Regular", size: 20))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color(red: 253/255, green: 250/255, blue: 240/255))
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            )
                    }
                }
            }
        }
    }
}
// MARK: - Left page: situation recap + screenshot

struct SituationPageView: View {
    let page: StorybookPage
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 253/255, green: 250/255, blue: 240/255)
                    .frame(width: geo.size.width, height: geo.size.height)
                
                LinearGradient(
                    colors: [.black.opacity(0.18), .clear],
                    startPoint: .trailing,
                    endPoint: .center
                )
                .frame(width: geo.size.width * 0.15)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                VStack(spacing: geo.size.height * 0.045) {
                    if let situation = page.sections.first {
                        Text(situation.heading)
                            .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.05))
                            .multilineTextAlignment(.center)
                    }
                    
                    // TEMP hardcoded — will be replaced with the real
                    // gameplay screenshot once that flow is tested
                    Image("Cubby_Gameplay_NoCharacter 1")
                        .resizable()
                        .scaledToFill()
                        .frame(height: geo.size.height * 0.4)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    if let situation = page.sections.first {
                        Text(situation.body ?? "")
                            .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.04))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, geo.size.width * 0.1)
                .padding(.top, geo.size.height * 0.06)
            }
        }
    }
}

// MARK: - Right page: choice + outcome + reflection box

struct OutcomePageView: View {
    let page: StorybookPage
    
    private var nonTalkSections: [StorybookSection] {
        page.sections.dropFirst().filter { $0.questions == nil }
    }
    
    private var talkSection: StorybookSection? {
        page.sections.first { $0.questions != nil }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 253/255, green: 250/255, blue: 240/255)
                    .frame(width: geo.size.width, height: geo.size.height)
                
                LinearGradient(
                    colors: [.black.opacity(0.18), .clear],
                    startPoint: .leading,
                    endPoint: .center
                )
                .frame(width: geo.size.width * 0.15)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: geo.size.height * 0.045) {
                    ForEach(nonTalkSections, id: \.self) { section in
                        VStack(spacing: 6) {
                            Text(section.heading)
                                .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.05))
                                .multilineTextAlignment(.center)
                            if let body = section.body {
                                Text(body)
                                    .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.04))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
                    if let talk = talkSection {
                        talkBox(talk, geo: geo)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, geo.size.width * 0.1)
                .padding(.top, geo.size.height * 0.06)
            }
        }
    }
    
    private func talkBox(_ section: StorybookSection, geo: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Text(section.heading)
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.05))
                HStack {
                    Spacer()
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: geo.size.width * 0.08))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.questions ?? [], id: \.self) { q in
                    Text("•  \(q)")
                        .font(.custom("PlaypenSans-Regular", size: geo.size.width * 0.04))
                }
            }
        }
        .padding(geo.size.width * 0.03)
        .background(Color(red: 253/255, green: 235/255, blue: 200/255))
        .cornerRadius(16)
    }
}

#Preview {
    let sample = StorybookViewModel(pages: [
        StorybookPage(id: "storybook_1C", playerChose: "1C", sourceFile: "1C.json", pageType: .endingRecap, title: "Player Chose 1C",
                      sections: [
                        StorybookSection(heading: "What Happened Before?", body: "Mia had quietly moved a little farther.", questions: nil),
                        StorybookSection(heading: "What Did You do?", body: "Reaches over and takes a piece", questions: nil),
                        StorybookSection(heading: "What Happened After?", body: "Mia cried and stop playing", questions: nil),
                        StorybookSection(heading: "Let's Talk", body: nil, questions: ["Why Mia cried?"])
                      ]),
        StorybookPage(id: "storybook_1A", playerChose: "1A", sourceFile: "1A.json", pageType: .endingRecap, title: "Player Chose 1A",
                      sections: [
                        StorybookSection(heading: "What Happened Before?", body: "Mia moved farther away.", questions: nil),
                        StorybookSection(heading: "What Did You do?", body: "Noticed and asked", questions: nil),
                        StorybookSection(heading: "What Happened After?", body: "Mia cried and stop playing", questions: nil),
                        StorybookSection(heading: "Let's Talk", body: nil, questions: ["How did you make Mia smile again?"])
                      ])
    ])
    StorybookView(viewModel: sample)
}
