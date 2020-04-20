import SwiftUI

struct OnboardingView: View {
    var healthKitManager: HealthKitManagerProtocol
    private let notificationCenter: NotificationManagerProtocol = NotificationManager()
    @EnvironmentObject var userService: FirebaseUserService

    var body: some View {
        VStack {
            PageViewContainer(
                viewControllers: Page.pages.map {
                    UIHostingController(rootView: PageView(page: $0))
                },
                healthKitManager: healthKitManager,
                completion: {
                    withAnimation {
                        DispatchQueue.main.async {
                            self.userService.state = .notLoggedIn
                        }
                    }
                }
            ).environmentObject(FirebaseUserService())
             .frame(maxHeight: .infinity).background(Color.pink).edgesIgnoringSafeArea(.all)
        }.onAppear {
            self.notificationCenter.requestNotificationAuthorizationIfNeeded()
        }
    }
}
