import SwiftUI

struct CharacterSelectionView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 2/255, green: 64/255, blue: 35/255)
                    .ignoresSafeArea()

                Image("Character_selection_background")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                Image("Pilih_karaktermu")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width * 0.58)
                    .offset(y: -geo.size.height * 0.32)

                Text("Choose Your Character")
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.044))
                    .foregroundStyle(.white)
                    .offset(y: -geo.size.height * 0.32)

                HStack(spacing: geo.size.width * 0.06) {
                    characterCard(id: "joey", name: "Joey", polaroid: "Joey_polaroid", pin: "Left_Pin",  pinOffsetX: -0.15, pinOffsetY: -0.10, nameRotation: -4, namePadding: 0.135, mirrored: false, geo: geo)
                    characterCard(id: "mia",  name: "Mia",  polaroid: "Mia_polaroid",  pin: "Right_Pin", pinOffsetX:  0.15, pinOffsetY: -0.10, nameRotation:  3, namePadding: 0.115, mirrored: true,  geo: geo)
                }
                .offset(y: geo.size.height * 0.08)

                Button {
                    router.current = .landing
                } label: {
                    Image("Back_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.09)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(geo.size.width * 0.028)
            }
        }
    }

    private func characterCard(id: String, name: String, polaroid: String, pin: String, pinOffsetX: Double, pinOffsetY: Double, nameRotation: Double, namePadding: Double, mirrored: Bool, geo: GeometryProxy) -> some View {
        let cardWidth = geo.size.width * 0.33
        return Image(polaroid)
            .resizable()
            .scaledToFit()
            .scaleEffect(x: mirrored ? -1 : 1, y: 1)
            .frame(width: cardWidth)
            .overlay(alignment: .bottom) {
                Text(name)
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.038))
                    .foregroundStyle(.black.opacity(0.70))
                    .rotationEffect(.degrees(nameRotation))
                    .padding(.bottom, cardWidth * namePadding)
            }
            .overlay(alignment: .top) {
                Image(pin)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth * 0.28)
                    .offset(x: geo.size.width * pinOffsetX, y: cardWidth * pinOffsetY)
            }
            .onTapGesture {
                router.current = .characterBio(character: id)
            }
    }
}

#Preview {
    CharacterSelectionView()
        .environment(AppRouter())
}
