//
//  StorybookView.swift
//  Cubby
//

import SwiftUI

struct StorybookView: View {
    var viewModel: StorybookViewModel
    var onExit: () -> Void = {}
    @State private var showClosing = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
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

                        HStack(spacing: 20) {
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

                            if viewModel.isLastPage {
                                Text("Finish")
                                    .font(.custom("FredokaOne-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.orange))
                                    .onTapGesture { showClosing = true }
                            }
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showClosing) {
            ClosingView(
                onBackToPlayground: onExit,
                onTryAgain: onExit
            )
        }
    }
}
// MARK: - Left page: situation recap + screenshot

struct SituationPageView: View {
    let page: StorybookPage
    let screenshot: UIImage?

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

                    if let screenshot {
                        Image(uiImage: screenshot)
                            .resizable()
                            .scaledToFill()
                            .frame(height: geo.size.height * 0.4)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: geo.size.height * 0.4)
                            .overlay(Text("No screenshot yet").foregroundColor(.gray))
                    }

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
