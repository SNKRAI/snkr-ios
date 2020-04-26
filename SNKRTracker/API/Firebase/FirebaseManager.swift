import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import Firebase
import Combine
import HealthKit

enum Entry {
    case runs([HKWorkout])
    case sneaker(Sneaker)
    case workout(RunningWorkoutContainer, SneakerContainer)
}

protocol FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void)
}

final class FirebaseManager: ObservableObject {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
}

extension FirebaseManager: FirebaseSaverProtocol {
    func save(entry: Entry, completion: @escaping (Swift.Result<Void, AppError>) -> Void) {
        switch entry {
        case .runs(let runs):
            let keys = Keys(collection: .userId, document: .pendingWorkouts)
            for run in runs {
                let collectionId = Helper.path(for: keys.collection)
                let json: [String: Any] = [
                    "duration": run.duration,
                    "startDate": run.startDate,
                    "endDate": run.endDate,
                    "totalDistance": run.totalDistance?.doubleValue(for: .mile()),
                    "totalEnergyBurned": run.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
                    "metadata": run.metadata
                ]
                
                firestore.collection(collectionId).document(keys.document.rawValue).setData([UUID().uuidString: json], merge: true) { err in
                    if let err = err {
                        completion(.failure(.generic(err.localizedDescription)))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        case .sneaker(let sneaker):
            print("SAVE")
//            saveToFirestore(model: sneaker, keys: Keys(collection: .userId, document: .sneakers), completion: completion)
            
        case .workout(let run, let sneaker):
            let saveKeys = Keys(collection: .userId, document: .sneakers)
            let collectionId = Helper.path(for: saveKeys.collection)
            
            firestore.collection(collectionId).document(saveKeys.document.rawValue).updateData([
                "\(sneaker.id).workouts.\(run.id)": run
            ]) { error in
                guard error == nil else {
                    completion(.failure(.generic(error?.localizedDescription ?? "")))
                    return
                }
                completion(.success(()))
            }
        }
    }
}
