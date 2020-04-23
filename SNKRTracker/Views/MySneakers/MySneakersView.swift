import SwiftUI

enum Source {
    case pendingWorkout(RunningWorkoutContainer), runsView
}

struct MySneakersView: View {
    @EnvironmentObject var viewModel: MySneakersViewModel
    let source: Source

    var body: some View {
        NavigationView {
            VStack {
                stateView
            }.onAppear {
                self.viewModel.fetchMySneakers()
            }
        }
    }

    private var stateView: AnyView {
        switch viewModel.state {
        case .loading:
            return AnyView(Text("Loading"))
        case .empty:
            return AnyView(
                PrimaryButton(
                    text: "Add",
                    destination: SneakerSearchView().environmentObject(SneakerSearchViewModel())
                ).navigationBarItems(trailing: Text(""))
            )
        case .fetched(let container):
            return AnyView(
                SneakerCardView(container: container, viewModel: viewModel, source: source)
            )
            
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
