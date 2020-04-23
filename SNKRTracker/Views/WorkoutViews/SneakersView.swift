import SwiftUI

struct SneakersView: View {
    var sneakers: [SneakerContainer]

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: HeaderView(text: "My Sneakers").padding(.vertical, Layout.headerPadding)) {
                VStack(spacing: Layout.headerPadding) {
                    ForEach(sneakers) { sneaker in
                        VStack {
                            Text("\(sneaker.data.company)")
                        }
                        .frame(width: UIScreen.main.bounds.width - (Layout.headerPadding * 2), height: 200)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
            }
        }
    }
}
