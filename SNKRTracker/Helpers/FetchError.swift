enum FetchError: Error {
    case firebaseError
    case decododingError
    case reason(String)
    var localizedDescription: String {
        switch self {
        case .reason(let message):
            return message
        case .firebaseError:
            return "Something went wrong when loading data from firebase"
        case .decododingError:
            return "Decoding error"
        }
    }
}
