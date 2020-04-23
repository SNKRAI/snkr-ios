import SwiftUI

struct HeaderButtonView<T: View>: View {
    let text: String
    var title: String
    var destination: T
    
    var body: some View {
        HStack {
            HeaderView(text: text)
            Spacer()
            NavigationLink(destination: destination) {
                Text(title)
            }
        }
    }
}

struct HeaderView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .fontWeight(.heavy)
    }
}
