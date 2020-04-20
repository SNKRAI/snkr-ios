import Foundation
import Firebase

enum Event: String {
    case loginPressedTest
}

protocol TrackingProtocol {
    func track(event: Event)
}

final class TrackingService { }

extension TrackingService: TrackingProtocol {
    func track(event: Event) {
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
}
