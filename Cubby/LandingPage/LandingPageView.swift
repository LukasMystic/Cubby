import SwiftUI

struct LandingPageView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Image("Primary-BG-LandingPage-Image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack(spacing: 400) {
                Image("Primary-Text-LandingPage-Image")
                Button("Start Game") {
                    router.current = .characterSelection
                }
                .font(.custom("FredokaOne-Regular", size: 48))
                .foregroundColor(Color(red: 2/255, green: 64/255, blue: 35/255))
                .padding(.horizontal, 120)
                .padding(.vertical, 24)
                .background(.white.opacity(0.65), in: Capsule())
                .accessibilityLabel("Play Button")
            }

        }
    }
}

#Preview {
    LandingPageView()
        .environment(AppRouter())
}
