import SwiftUI
import HealthKit

struct MyRunsView: View {
    @EnvironmentObject var viewModel: MyRunsViewModel
    private let userService: FirebaseUserServiceProtocol = FirebaseUserService()
    private let searchViewModel = SneakerSearchViewModel()

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
                },
                trailing:
                Button("Logout") {
                    self.userService.logout()
                }
            )
        }
        .sheet(isPresented: $shouldModal) {
            MySneakersView(source: .runsView, completion: {
                print("??")
            }) { sneaker in
                self.viewModel.append(sneaker: sneaker)
            }.environmentObject(MySneakersViewModel())
        }
    }

    private var stateView: AnyView {
        switch viewModel.state {
        case .loading:
            return AnyView(Text("Loading"))
        case .empty:
            return AnyView(
                VStack {
                    Text("No pening workouts, no sneakers")
                    Text("Let's start by adding some shoes?")
                    Buttons.sneakerSearchButton() { sneaker in
                        self.viewModel.append(sneaker: sneaker)
                    }
                }
            )
        case .fetched(let pendingWorkouts, let sneakers):
            return AnyView(
                ScrollView(.vertical, showsIndicators: false) {
                    PendingRunsView(runs: pendingWorkouts, sneakers: sneakers, completion: {
                        self.viewModel.fetch()
                    }) { sneaker in
                        self.viewModel.append(sneaker: sneaker)
                    }
                
                    SneakersView(sneakers: sneakers, searchViewModel: searchViewModel) { sneaker in
                        self.viewModel.append(sneaker: sneaker)
                    }
                }
            )
            case .error(let reason):
                return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
