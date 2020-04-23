import SwiftUI

struct SneakerCardRow: View {
    var sneaker: Sneaker
    var body: some View {
        VStack {
            Text(sneaker.company)
            Text(sneaker.model)
        }
        .frame(width: UIScreen.main.bounds.width - (Layout.padding * 2), height: 200)
        .background(Color.gray)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
