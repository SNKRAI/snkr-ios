import SwiftUI

struct SneakerSearchView: View {
    @EnvironmentObject var viewModel: SneakerSearchViewModel
    @Environment(\.presentationMode) var presentation
    @State private var searchText = ""
    var completion: ((SneakerContainer) -> Void)

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
                var filtered: [SneakerContainer]
                if searchText.isEmpty {
                    filtered = sneakers.compactMap { $0 }
                } else {
                    filtered = sneakers.compactMap { $0 }.filter { $0.data.model.localizedStandardContains(searchText) || $0.data.company.localizedStandardContains(searchText)
                    }
                }
                return AnyView(
                    List {
                        ForEach(filtered) { sneaker in
                            Button(action: {
                                self.viewModel.add(sneaker.data) {
                                    self.presentation.wrappedValue.dismiss()
                                    self.completion(sneaker)
                                }
                            }) {
                                Text(sneaker.data.model)
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
