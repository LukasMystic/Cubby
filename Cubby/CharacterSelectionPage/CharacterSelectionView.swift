import SwiftUI

struct CharacterSelectionView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Primary-BG-CharacterSelection-Image")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Image("Secondary-BG-CharacterSelection-Image")
                    .resizable()
                    .scaleEffect(1.05)
                    .rotationEffect(.degrees(2))
                Rectangle()
                    .frame(width: geo.size.width * 0.58, height: geo.size.height * 0.15)
                    .offset(y: -geo.size.height * 0.39)
                    .rotationEffect(.degrees(2.64))
                    .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
                Text("Pilih Karaktermu")
                    .font(.custom("FredokaOne-Regular", size: geo.size.width * 0.047))
                    .foregroundColor(.white)
                    .offset(y: -geo.size.height * 0.39)
                    .rotationEffect(.degrees(2.64))
                HStack(spacing: -geo.size.width * 0.146) {
                    ForEach(Array(Character.all.values), id: \.id) { character in
                        Image(character.imageName)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.67)
                            .onTapGesture {
                                router.current = .characterBio(character: character.id)
                            }
                    }
                }
                .offset(y: geo.size.height * 0.015)
            }
        }
    }
}

#Preview {
    CharacterSelectionView()
        .environment(AppRouter())
}
