import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import Firebase
import Combine

enum Entry {
    case runs([RunningWorkout])
    case sneaker(Sneaker)
}

protocol FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void)
}

final class FirebaseManager: ObservableObject {
    private let keys: Keys
    private let firestore: Firestore

    init(keys: Keys, firestore: Firestore = Firestore.firestore()) {
        self.keys = keys
        self.firestore = firestore
    }
    
    private func saveToFirestore<T: Encodable>(model: T, completion: @escaping (Swift.Result<Void, AppError>) -> Void) {
        let collectionId = Helper.path(for: keys.collection)
        do {
            guard let encoded = try FirebaseEncoder().encode(model) as? [String: Any] else { return }
            firestore.collection(collectionId).document(keys.document.rawValue).setData([UUID().uuidString: encoded], merge: true) { err in
                if let err = err {
                    completion(.failure(.generic(err.localizedDescription)))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            print("error")
        }
    }
}

extension FirebaseManager: FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void) {
        switch entry {
        case .runs(let runs):
            for run in runs {
                saveToFirestore(model: run, completion: completion)
            }
        case .sneaker(let sneaker):
            saveToFirestore(model: sneaker, completion: completion)
        }
    }
}
