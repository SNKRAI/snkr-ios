import SwiftUI

struct HeaderView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .fontWeight(.heavy)
    }
}
