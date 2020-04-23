import SwiftUI

struct SneakersView: View {
    var sneakers: [SneakerContainer]
    var completion: (Sneaker) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header: HeaderButtonView(text: "My Sneakers", title: "Add more", destination: SneakerSearchView().environmentObject(SneakerSearchViewModel())).padding(.horizontal, Layout.padding)) {
                VStack(spacing: Layout.padding) {
                    ForEach(sneakers) { sneaker in
                        SneakerCardRow(sneaker: sneaker.data)
                    }
                }.padding(Layout.padding)
            }
        }
    }
}
