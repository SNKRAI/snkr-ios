import SwiftUI
import HealthKit

struct MyRunsView: View {
    @EnvironmentObject var viewModel: MyRunsViewModel

    private let userService: FirebaseUserServiceProtocol = FirebaseUserService()
    
    @State var shouldModal = false

    var body: some View {
        NavigationView {
            VStack {
                stateView
                .navigationBarTitle("My runs")
                .navigationBarItems(leading:
                    Button("My Sneakers") {
                        self.shouldModal = true
                    }, trailing:
                    Button("Logout") {
                        self.userService.logout()
                    }
                )
            }
        }.sheet(isPresented: $shouldModal) {
            MySneakersView().environmentObject(MySneakersViewModel())
        }
    }

    private var stateView: AnyView {
        switch viewModel.state {
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
