import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class FetchService<T: Codable> {
    private let key: Key
    private let firestore: Firestore
    
    init(key: Key, firestore: Firestore = Firestore.firestore()) {
        self.key = key
        self.firestore = firestore
    }
    
    func fetch(completion: @escaping (LoadableState<[T]>) -> Void) {
        let collectionId = path(for: key.collection)
        let ref = firestore.collection(collectionId).document(key.document.rawValue)

        ref.getDocument { document, error in
            guard error == nil else {
                completion(.error(.firebaseError))
                return
            }
            
            if let document = document, let data = document.data(), document.exists {
                do {
                     let decoded = try FirebaseDecoder().decode([String: T].self, from: data).map { $0.value }
                    if decoded.isEmpty {
                        completion(.empty)
                    } else {
                        completion(.fetched(decoded))
                    }
                 } catch let error {
                    completion(.error(.decododingError))
                 }
            } else {
                completion(.error(.firebaseError))
            }
        }
    }
    
    private func path(for collection: Collection) -> String {
        switch collection {
        case .userId:
            return Auth.auth().currentUser?.uid ?? ""
        default:
            return collection.rawValue
        }
    }
}
