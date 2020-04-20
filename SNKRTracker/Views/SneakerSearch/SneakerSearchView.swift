import SwiftUI

struct SneakerSearchView: View {
    @EnvironmentObject var viewModel: SneakerSearchViewModel

    @State private var searchText = ""

    var body: some View {
        
        VStack {
            SearchBar(text: $searchText)
            stateView
        }
        .navigationBarTitle(Text("Search"))
    }
    
    private var stateView: AnyView {
        switch viewModel.state {
            case .loading:
                return AnyView(Text("Loading"))
            case .fetched(let sneakers):
                return AnyView(
                    List(sneakers) { sneaker in
                        Text(sneaker.model)
                    }
                )
            
        case .empty:
            return AnyView(Text("EMPTY"))
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
