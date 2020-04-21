enum Constants: String {
    case workouts
    case sneakers
    case allSneakers
    case models
}


struct Keys {
    let collection: Collection
    let document: Document
}

enum Collection: String {
    case userId
    case allSneakers
    case sneakers
}

enum Document: String {
    case models
    case workouts
    case sneakers
}

import FirebaseAuth
class Helper {
    static func path(for collection: Collection) -> String {
        switch collection {
        case .userId:
            return Auth.auth().currentUser?.uid ?? ""
        default:
            return collection.rawValue
        }
    }
}
