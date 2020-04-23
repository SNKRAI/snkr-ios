import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class FetchService {
    private let keys: Keys
    private let firestore: Firestore
    
    init(keys: Keys, firestore: Firestore = Firestore.firestore()) {
        self.keys = keys
        self.firestore = firestore
    }
    
    func fetch<T: Decodable>(completion: @escaping (LoadableState<[Container<T>]>) -> Void) {
        let collectionId = Helper.path(for: keys.collection)
        let ref = firestore.collection(collectionId).document(keys.document.rawValue)

        ref.getDocument { document, error in
            guard error == nil else {
                completion(.error(.firebaseError))
                return
            }
            
            if let document = document, let data = document.data(), document.exists {
                do {
                    let decoded = try FirebaseDecoder().decode([String: T].self, from: data).map { Container(id: $0.key, data: $0.value) }
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
    
    func delete(containerId: String, completion: @escaping (Swift.Result<Void, FetchError>) -> Void) {
        let collectionId = Helper.path(for: keys.collection)
        let ref = firestore.collection(collectionId).document(keys.document.rawValue)
        
        ref.updateData([
            containerId: FieldValue.delete()
        ]) { error in
            guard error == nil else {
                completion(.failure(.reason("could not delete \(containerId)")))
                return
            }
            completion(.success(()))
        }
    }
}
