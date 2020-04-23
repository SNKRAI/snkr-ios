import SwiftUI

struct HeaderButtonView<T: View>: View {
    let text: String
    var title: String
    var destination: T
    
    @State private var showModal = false
    
    var body: some View {
        HStack {
            HeaderView(text: text)
            Spacer()
            Button(action: {
                self.showModal = true
            }) {
                Text(title)
            }.sheet(isPresented: self.$showModal) {
                self.destination
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
