import SwiftUI

struct MySneakersView: View {
    @EnvironmentObject var viewModel: MySneakersViewModel

    var body: some View {
        NavigationView {
            VStack {
                stateView
                .navigationBarItems(trailing:
                    NavigationLink(destination:                 SneakerSearchView().environmentObject(SneakerSearchViewModel())
                    ) {
                        Text("Add more")
                    }
                )
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
        case .fetched(let sneakers):
            return AnyView(
                List {
                    ForEach(sneakers, id: \.self) { sneaker in
                        Text(sneaker.model)
                    }.onDelete { indexSet in
                        guard let index = Array(indexSet).first else { return }
                        self.viewModel.delete(sneaker: sneakers[index])
                    }
                }
            )
            

        case .error(let reason):
            return AnyView(Text("Error \(reason.localizedDescription)"))
        }
    }
}
