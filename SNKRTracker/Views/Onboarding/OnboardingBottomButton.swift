import SwiftUI

struct OnboardingBottomButton: View {
    var text = ""
    var action: (() -> Void) = { }
    
    var body: some View {
      Button(action: {
        self.action()
      }) {
        HStack {
            Text(text)
                .bold()
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.vertical)
                .accentColor(Color.white)
                .background(Color("accentColor"))
                .cornerRadius(30)
            }
        }
    }
}
