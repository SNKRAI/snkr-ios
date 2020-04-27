import FirebaseAuth
import FirebaseFirestore
import HealthKit

protocol FetchServiceProtocol {
    var runninWorkoutContainer: [RunningWorkoutContainer] { get set }
    var sneakerContainer: [SneakerContainer] { get set }
    func fetchAllDocuments(collection: Collection, completion: @escaping (MainState) -> Void)
    func fetch(with keys: Keys, completion: @escaping (SneakerState) -> Void)
    func delete(for keys: Keys, containerId: String, completion: @escaping (Swift.Result<Void, FetchError>) -> Void)
}

class FetchService {
    var runninWorkoutContainer = [RunningWorkoutContainer]()
    var sneakerContainer = [SneakerContainer]()

    private let firestore: Firestore
    private var errors = [FetchError]()
    
    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    private func sortData(from document: QueryDocumentSnapshot) {
        guard let documentType = Document(rawValue: document.documentID) else { return }
        switch documentType {
        case .sneakers:
            for data in document.data() {
                parseSneaker(key: data.key, values: data.value) { [weak self] sneaker in
                    guard let self = self else { return }
                    self.sneakerContainer.append(sneaker)
                }
            }
        case .pendingWorkouts:
            for data in document.data() {
                guard let values = data.value as? [String: Any],
                    let duration = values["duration"] as? TimeInterval,
                    let startDate = values["startDate"] as? Timestamp,
                    let endDate = values["endDate"] as? Timestamp else { continue }
                
                let totalDistance = HKQuantity(unit: .mile(), doubleValue: values["totalDistance"] as? Double ?? 0.0)
                let totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: values["totalEnergyBurned"] as? Double ?? 0.0)
                let metadata = values["metadata"] as? [String: Any]
                let workout = HKWorkout(activityType: .running, start: startDate.dateValue(), end: endDate.dateValue(), duration: duration, totalEnergyBurned: totalEnergyBurned, totalDistance: totalDistance, device: nil, metadata: metadata)
                runninWorkoutContainer.append(RunningWorkoutContainer(id: data.key, data: workout))
            }
        default:
            break
        }
    }
    
    private func parseSneaker(key: String, values: Any, completion: @escaping (SneakerContainer) -> Void) {
        var localContainer = [RunningWorkoutContainer]()

        guard let values = values as? [String: Any] else { return }
        if let company = values["company"] as? String,
            let model = values["model"] as? String {
        
            if let workouts = values["workouts"] as? [String: Any] {
                for workout in workouts {
                    self.parseWorkout(key: workout.key, values: workout.value) { container in
                        localContainer.append(container)
                    }
                }
                
                completion(SneakerContainer(id: key, data: Sneaker(company: company, model: model, workouts: localContainer)))
            } else {
                completion(SneakerContainer(id: key, data: Sneaker(company: company, model: model, workouts: [])))
            }
        } else {
            print("error")
        }
    }
    
    private func parseWorkout(key: String, values: Any, completion: @escaping (RunningWorkoutContainer) -> Void) {
        guard let values = values as? [String: Any],
            let duration = values["duration"] as? TimeInterval,
            let startDate = values["startDate"] as? Timestamp,
            let endDate = values["endDate"] as? Timestamp else { return }

        let totalDistance = HKQuantity(unit: .mile(), doubleValue: values["totalDistance"] as? Double ?? 0.0)
        let totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: values["totalEnergyBurned"] as? Double ?? 0.0)
        let metadata = values["metadata"] as? [String: Any]
        let workout = HKWorkout(activityType: .running, start: startDate.dateValue(), end: endDate.dateValue(), duration: duration, totalEnergyBurned: totalEnergyBurned, totalDistance: totalDistance, device: nil, metadata: metadata)
        completion(RunningWorkoutContainer(id: key, data: workout))
    }
}

extension FetchService: FetchServiceProtocol {
    func fetchAllDocuments(collection: Collection, completion: @escaping (MainState) -> Void) {
        
        runninWorkoutContainer = []
        sneakerContainer = []
    
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

    func fetch(with keys: Keys, completion: @escaping (SneakerState) -> Void) {
        let group = DispatchGroup()
        let collectionId = Helper.path(for: keys.collection)
        let ref = firestore.collection(collectionId).document(keys.document.rawValue)
        var localContainer = [SneakerContainer]()

        ref.getDocument { [weak self] document, error in
            guard let self = self, error == nil else {
                completion(.error(.firebaseError))
                return
            }
            
            if let document = document, let data = document.data(), document.exists {
                for i in data {
                    group.enter()
                    self.parseSneaker(key: i.key, values: i.value) { sneaker in
                        localContainer.append(sneaker)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                completion(.fetched(localContainer))
            }
        }
    }
    
    func delete(for keys: Keys, containerId: String, completion: @escaping (Swift.Result<Void, FetchError>) -> Void) {
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
