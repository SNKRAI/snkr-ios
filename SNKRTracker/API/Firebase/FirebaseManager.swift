import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import Firebase
import Combine

enum Entry {
    case runs([RunningWorkout])
}

protocol FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void)
}

final class FirebaseManager: ObservableObject {
    private let database: Firestore

    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }
}

extension FirebaseManager: FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void) {
        switch entry {
        case .runs(let runs):
            guard let userId = Auth.auth().currentUser?.uid else { return }
            do {
                for run in runs {
                    guard let encoded = try FirebaseEncoder().encode(run) as? [String: Any] else { continue }
                    database.collection(userId).document(Constants.workouts).setData([run.id.uuidString: encoded], merge: true) { err in
                        if let err = err {
                            completion(.failure(.generic(err.localizedDescription)))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            } catch let error {
                print("error")
            }
        }
    }
}
