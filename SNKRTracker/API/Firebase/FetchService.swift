import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

protocol FetchServiceProtocol {
    func fetchAllDocuments(collection: Collection, completion: @escaping (FetchState<[RunningWorkoutContainer], [SneakerContainer]>) -> Void)
    func fetch<T: Decodable>(with keys: Keys, completion: @escaping (LoadableState<[Container<T>]>) -> Void)
    func delete(containerId: String, completion: @escaping (Swift.Result<Void, FetchError>) -> Void)
}

class FetchService {
    private let firestore: Firestore
    private var runninWorkoutContainer = [RunningWorkoutContainer]()
    private var sneakerContainer = [SneakerContainer]()
    private var errors = [FetchError]()
    
    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    private func sortData(from document: QueryDocumentSnapshot) {
        guard let documentType = Document(rawValue: document.documentID) else { return }
        switch documentType {
        case .sneakers:
            if let decoded = decode(data: document.data(), into: [String: Sneaker].self) {
                sneakerContainer.append(contentsOf: decoded)
            } else {
                errors.append(.decododingError)
            }
        case .pendingWorkouts:
            if let decoded = decode(data: document.data(), into: [String: RunningWorkout].self) {
                runninWorkoutContainer.append(contentsOf: decoded)
            } else {
                errors.append(.decododingError)
            }
        default:
            break
        }
    }
    
    private func decode<T: Codable & Hashable>(data: [String: Any], into type: [String: T].Type) -> [Container<T>]? {
        do {
            return try FirebaseDecoder().decode(type, from: data).map { Container(id: $0.key, data: $0.value) }
        } catch let error {
            print("Decoding error: \(error.localizedDescription)")
        }
        return nil
    }
}

extension FetchService: FetchServiceProtocol {
    func fetchAllDocuments(collection: Collection, completion: @escaping (FetchState<[RunningWorkoutContainer], [SneakerContainer]>) -> Void) {
        let collectionId = Helper.path(for: collection)
        let ref = firestore.collection(collectionId)
        
        ref.getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            for document in documents {
                self.sortData(from: document)
            }

            guard self.errors.isEmpty else {
                completion(.error(.reason(self.errors.first?.localizedDescription ?? "document fetch error")))
                return
            }
            if self.runninWorkoutContainer.isEmpty && self.sneakerContainer.isEmpty {
                completion(.empty)
                return
            }

            completion(.fetched(self.runninWorkoutContainer, self.sneakerContainer))
        }
    }

    func fetch<T: Decodable>(with keys: Keys, completion: @escaping (LoadableState<[Container<T>]>) -> Void) {
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
        let keys = Keys(collection: .userId, document: .sneakers)
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
