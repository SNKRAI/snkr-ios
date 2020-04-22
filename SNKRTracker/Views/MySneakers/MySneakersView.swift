import SwiftUI

struct MySneakersView: View {
    @EnvironmentObject var viewModel: MySneakersViewModel

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
                )
            )
        case .fetched(let container):
            return AnyView(
                List {
                    ForEach(container, id: \.self) { sneaker in
                        Text(sneaker.data.model)
                    }.onDelete { indexSet in
                        self.viewModel.delete(at: indexSet, in: container)
                    }
                }
            )
            
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
