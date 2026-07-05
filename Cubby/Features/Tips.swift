import SwiftUI
import TipKit

struct JoystickTip: Tip {
    var title: Text { Text("Joystick Control") }
    var message: Text { Text("Drag the joystick to walk.")}
    var image: Image? { Image(systemName: "gamecontroller") }
}

struct InteractTip: Tip {
    static let useJoystick = Event(id: "useJoystick")

        var title: Text { Text("Interact") }
    var message: Text { Text("Tap to talk to friends nearby.")}
    var image: Image? { Image(systemName: "hand.raised.fill") }

    var rules: [Rule] {
        #Rule(Self.useJoystick) { $0.donations.count >= 1 }
    }

}
