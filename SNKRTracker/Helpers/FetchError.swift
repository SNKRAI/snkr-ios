enum FetchError: Error {
    case reason(String)
    var localizedDescription: String {
        switch self {
        case .reason(let message):
            return message
        }
    }
}
