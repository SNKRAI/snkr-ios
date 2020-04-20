import SwiftUI

struct MySneakersView: View {
    @EnvironmentObject var viewModel: MySneakersViewModel
    
    var body: some View {
        NavigationView {
            VStack { stateView }
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
        case .fetched(let sneakers):
            return AnyView(
                List(sneakers) { sneaker in
                    Text(sneaker.model)
                }
            )
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
