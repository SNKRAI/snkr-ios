import SwiftUI

struct PrimaryButton<T: View>: View {
    let text: String
    let destination: T
    
    var body: some View {
        NavigationLink(text, destination: destination)
            // TODO: Change style
            .foregroundColor(Color.white)
            .frame(width: UIScreen.main.bounds.width - 100, height: 20, alignment: .bottom)
            .padding()
            .background(Color.green)
            .cornerRadius(5)
    }
}
