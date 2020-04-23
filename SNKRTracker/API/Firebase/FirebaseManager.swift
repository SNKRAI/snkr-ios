import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import Firebase
import Combine

enum Entry {
    case runs([RunningWorkout])
    case sneaker(Sneaker)
    case workout(RunningWorkout)
}

protocol FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void)
}

final class FirebaseManager: ObservableObject {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    
    private func saveToFirestore<T: Encodable>(model: T, keys: Keys, completion: @escaping (Swift.Result<Void, AppError>) -> Void) {
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
                saveToFirestore(model: run, keys: Keys(collection: .userId, document: .pendingWorkouts), completion: completion)
            }
        case .sneaker(let sneaker):
            saveToFirestore(model: sneaker, keys: Keys(collection: .userId, document: .sneakers), completion: completion)
            
        case .workout(let run):
            print("fef")
        }
    }
}
