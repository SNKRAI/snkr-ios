import SwiftUI

struct SneakersView: View {
    var sneakers: [SneakerContainer]
    let searchViewModel: SneakerSearchViewModel
    var completion: (SneakerContainer) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header: HeaderButtonView(text: "My Sneakers", title: "Add more", destination: SneakerSearchView() { sneaker in
                    self.completion(sneaker)
                }.environmentObject(searchViewModel)).padding(.horizontal, Layout.padding)) {
                VStack(spacing: Layout.padding) {
                    sneakersView
                }.padding(Layout.padding)
            }
        }
    }
    
    private var sneakersView: AnyView {
        if sneakers.isEmpty {
            return AnyView(
                Buttons.sneakerSearchButton() { sneaker in
                    self.completion(sneaker)
                }
            )
        } else {
            return AnyView(
                ForEach(sneakers) { sneaker in
                    NavigationLink(destination: SneakersWorkoutsView(sneaker: sneaker)) {
                        SneakerCardRow(sneaker: sneaker.data)
                    }
                }
            )
        }
    }
}
