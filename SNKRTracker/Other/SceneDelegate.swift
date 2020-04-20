import UIKit
import SwiftUI
import HealthKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
 
    var window: UIWindow?

    func sceneWillEnterForeground(_ scene: UIScene) {
        let contentView = MainView().environmentObject(FirebaseUserService())

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
