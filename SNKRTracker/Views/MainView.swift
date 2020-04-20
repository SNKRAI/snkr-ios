import SwiftUI
import HealthKit
import FirebaseAuth

struct MainView: View {

    let healthKitManager: HealthKitManagerProtocol = HealthKitManager()
    @EnvironmentObject var userService: FirebaseUserService

    var body: some View {
        VStack { stateView }
    }

    private var stateView: AnyView {
        switch userService.state {
        case .firstLaunch:
            return AnyView(OnboardingView(healthKitManager: healthKitManager))
        case .loading:
            return AnyView(Text("Loading"))
        case .notLoggedIn:
            return AnyView(LoginView().transition(.move(edge: .bottom)))
        case .loggedIn(let user):
            return AnyView(MyRunsView().environmentObject(FirebaseLoader()))
        }
    }
}

