import UIKit

enum LoginMethod {
    case google
}

struct LoginButton {
    let method: LoginMethod
    let title: String
    let color: UIColor
}
