enum Constants: String {
    case workouts
    case sneakers
    case allSneakers
    case models
}


struct Key {
    let collection: Collection
    let document: Document
}

enum Collection: String {
    case userId
    case allSneakers
}

enum Document: String {
    case models
    case workouts
    case sneakers
}
