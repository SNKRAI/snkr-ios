import SwiftUI
import HealthKit

struct MyRunsView: View {
    @EnvironmentObject var viewModel: MyRunsViewModel

    private let userService: FirebaseUserServiceProtocol = FirebaseUserService()
    
    @State var shouldModal = false
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    var body: some View {
        NavigationView {
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
        }.sheet(isPresented: $shouldModal) {
            MySneakersView(source: .runsView).environmentObject(MySneakersViewModel())
        }
    }

    private var stateView: AnyView {
        switch viewModel.state {
        case .loading:
            return AnyView(Text("Loading"))
        case .empty:
            return AnyView(Text("EMPTY"))
        case .fetched(let runs):
            let sorted = viewModel.sort(runs: runs)
            return AnyView(
                ScrollView(.vertical, showsIndicators: false) {
                    PendingRunsView(runs: sorted.pending)
                    SneakerWorkoutView(runs: sorted.past)
                }
            )
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
