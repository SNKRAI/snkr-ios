import SwiftUI
import HealthKit

struct MyRunsView: View {
    @EnvironmentObject var firebaseLoader: FirebaseLoader

    private let userService: FirebaseUserServiceProtocol = FirebaseUserService()

    var body: some View {
        NavigationView {
            VStack {
                stateView
                .navigationBarTitle("My runs")
                .navigationBarItems(trailing:
                    Button("Logout") {
                        self.userService.logout()
                    }
                )
            }
        }.onAppear {
            self.firebaseLoader.fetch()
        }
    }

    var stateView: AnyView {
        switch firebaseLoader.state {
        case .loading:
            return AnyView(Text("Loading"))
        case .empty:
            return AnyView(Text("EMPTY"))
        case .fetched(let runs):
            return AnyView(
                List(runs) { run in
                    Text("\(run.totalDistance!)")
                }
            )
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
