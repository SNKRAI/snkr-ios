import SwiftUI
import GoogleSignIn

struct LoginView: View {
    var body: some View {
        WrapedLoginViewController()
    }
}

import SwiftUI

struct WrapedLoginViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoginViewController {
        
        let buttons = [
            LoginButton(method: .google, title: "google", color: .red)
        ]
        
        let vc = LoginViewController(with: buttons)
        return vc
    }

    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) { }

    static func dismantleUIViewController(_ uiViewController: LoginViewController, coordinator: Self.Coordinator) { }
}
