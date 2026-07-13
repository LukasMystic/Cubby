import SwiftUI

struct CharacterBioView: View {
    @State private var viewModel: CharacterBioViewModel
    @Environment(AppRouter.self) private var router

    init(selectedCharacter: String) {
        _viewModel = State(wrappedValue: CharacterBioViewModel(selectedCharacter: selectedCharacter))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 2/255, green: 64/255, blue: 35/255)
                    .ignoresSafeArea()

                Image("Bio_Background")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                HStack(spacing: geo.size.width * 0.02) {
                    polaroidCard(geo: geo)
                    bioCard(geo: geo)
                }

                Button {
                    router.current = .characterSelection
                } label: {
                    Image("Back_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.09)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(geo.size.width * 0.028)

                Button {
                    router.current = .game
                } label: {
                    ZStack {
                        Image("Main_button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.24)
                        Text("Play")
                            .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.032))
                            .foregroundStyle(Color(red: 2/255, green: 64/255, blue: 35/255))
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, geo.size.width * 0.03)
                .padding(.bottom, geo.size.height * 0.01)
            }
        }
    }

    private func polaroidCard(geo: GeometryProxy) -> some View {
        let cardWidth = geo.size.width * 0.30
        let isMia = viewModel.character.id == "mia"
        let nameRotation: Double = isMia ? -3 : -4
        let namePadding: Double  = isMia ? 0.115 : 0.135

        return Image(viewModel.character.polaroidName)
            .resizable()
            .scaledToFit()
            .frame(width: cardWidth)
            .overlay(alignment: .bottom) {
                Text(viewModel.character.name)
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.032))
                    .foregroundStyle(.black.opacity(0.70))
                    .rotationEffect(.degrees(nameRotation))
                    .padding(.bottom, cardWidth * namePadding)
            }
    }

    private func bioCard(geo: GeometryProxy) -> some View {
        let cardWidth = geo.size.width * 0.305

        return ZStack {
            Image("Bio_paper")
                .resizable()
                .scaledToFit()
                .frame(width: cardWidth)

            VStack(alignment: .leading, spacing: geo.size.height * 0.032) {
                Text("Hi, I'm \(viewModel.character.name)!")
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.029))
                    .foregroundStyle(Color(red: 2/255, green: 64/255, blue: 35/255))

                Text(viewModel.character.bioText)
                    .font(.custom("Playpen Sans", size: geo.size.width * 0.020))
                    .foregroundStyle(.black.opacity(0.80))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .rotationEffect(.degrees(2))
            .frame(width: cardWidth * 0.60, alignment: .leading)
            .offset(x: cardWidth * 0.06, y: -cardWidth * 0.08)
        }
        .rotationEffect(.degrees(2))
    }
}

#Preview {
    CharacterBioView(selectedCharacter: "joey")
        .environment(AppRouter())
}
