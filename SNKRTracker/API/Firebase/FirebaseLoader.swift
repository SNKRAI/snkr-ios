import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import Combine

class FirebaseLoader: ObservableObject {
    private let changeObserver = PassthroughSubject<FirebaseLoader, Never>()
    private let healthKitManager: HealthKitManagerProtocol
    private let database: Firestore

    @Published var state: LoadableState<[RunningWorkout]> = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        database: Firestore = Firestore.firestore(),
        healthKitManager: HealthKitManagerProtocol = HealthKitManager()
    ) {
        self.database = database
        self.healthKitManager = healthKitManager
    }
    
    func fetch() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        healthKitManager.observeAndSaveWorkouts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchRunningWorkouts(for: userId)
            case .failure(let error):
                if case .noHealthKitPermissions = error {
                    self.healthKitManager.requestHealthKitPermissions { [weak self] result in
                        if case .success = result {
                            self?.fetchRunningWorkouts(for: userId)
                        }
                    }
                    
                    return
                }
    
                self.state = .error(.reason(error.localizedDescription))
            }
        }
    }
    
    private func fetchRunningWorkouts(for userId: String) {
        let ref = database.collection(userId).document(Constants.workouts)

        ref.getDocument { document, error in
            if let document = document, let data = document.data(), document.exists {
                do {
                    let decoded = try FirebaseDecoder().decode([String: RunningWorkout].self, from: data).map { $0.value }
                    self.state = decoded.isEmpty ? .empty : .fetched(decoded)
                } catch let error {
                    self.state = .error(.reason(error.localizedDescription))
                }
                
            } else {
                self.state = .error(.reason(error?.localizedDescription ?? "fetch error"))
            }
        }
    }
}

enum LoadableState<T> {
    case loading
    case empty
    case fetched(T)
    case error(FetchError)
}
