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
//        .alert(isPresented: self.$viewModel.hasAdded) {
//               Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
//        }
    }
    
    private var stateView: AnyView {
        switch viewModel.state {
            case .loading:
                return AnyView(Text("Loading"))
            case .fetched(let sneakers):
                var filtered: [Sneaker]
                if searchText.isEmpty {
                    filtered = sneakers.compactMap { $0.data }
                } else {
                    filtered = sneakers.compactMap { $0.data }.filter { $0.model.localizedStandardContains(searchText) || $0.company.localizedStandardContains(searchText)
                    }
                }
                return AnyView(
                    List {
                        ForEach(filtered, id: \.self) { sneaker in
                            Button(action: {
                                self.viewModel.add(sneaker)
                            }) {
                                Text(sneaker.model)
                            }
                        }
                    }
                )
        case .empty:
            return AnyView(Text("EMPTY"))
        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
