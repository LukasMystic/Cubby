import SwiftUI
import TipKit

struct JoystickTip: Tip {
    var title: Text { Text("Joystick").font(.custom("FredokaOne-Regular", size: 16)) }
    var message: Text? { Text("Drag the joystick to walk.").font(.custom("Playpen Sans", size: 14)) }
    var image: Image? { Image(systemName: "gamecontroller") }
}

struct InteractTip: Tip {
    static let useJoystick = Event(id: "useJoystick")
    static let useInteract = Event(id: "useInteract")

    var title: Text { Text("Interact").font(.custom("FredokaOne-Regular", size: 16)) }
    var message: Text? { Text("Tap to talk to friends nearby.").font(.custom("Playpen Sans", size: 14)) }
    var image: Image? { Image(systemName: "hand.raised.fill") }

    var rules: [Rule] {
        #Rule(Self.useJoystick) { $0.donations.count >= 1 }
    }
}

struct StartGameTip: Tip {
    var title: Text { Text("Start the Game!")}
    var message: Text? { Text("You're all set. Go explore!")}
    var image: Image? { Image(systemName: "play.circle.fill")}

    var rules: [Rule] {
        #Rule(InteractTip.useJoystick) { $0.donations.count >= 1}
        #Rule(InteractTip.useInteract) { $0.donations.count >= 1}
    }
}
