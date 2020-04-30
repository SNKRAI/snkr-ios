import Foundation
import HealthKit
import MapKit

final class HealthKitManager {
    private let healthStore = HKHealthStore()
    private var locations = [CLLocation]()
    private var savedAnchor: HKQueryAnchor?
    private let firebaseManager: FirebaseManager
    private let notificationCenter: NotificationManagerProtocol = NotificationManager()
    
    init(firebaseManager: FirebaseManager = FirebaseManager()) {
        self.firebaseManager = firebaseManager
    }

    func getRunningWorkouts(completion: @escaping (Result<[HKWorkout], AppError>) -> Void) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: 0, sortDescriptors: [sortDescriptor]
        ) { query, workouts, error in
            guard error == nil else {
                completion(.failure(.generic("Could not fetch runs")))
                return
            }

            guard let workouts = workouts as? [HKWorkout], !workouts.isEmpty else { return }
            completion(.success(workouts))
        }

        healthStore.execute(query)
    }
    
    // TODO: handle deprecated warnings
    private func saveRuns(completion: @escaping (Result<RunningCompletion, AppError>) -> Void) {
        if let anchorData = UserDefaults.standard.object(forKey: "anchor") as? Data {
            self.savedAnchor = NSKeyedUnarchiver.unarchiveObject(with: anchorData) as? HKQueryAnchor
        }

        let anchorQuery = HKAnchoredObjectQuery(type: .workoutType(), predicate: HealthConfiguration.runningPredicate, anchor: self.savedAnchor, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, anchor, error in
            guard let self = self, error == nil else {
                completion(.failure(.generic("anchor query error")))
                return
            }
            
            if let anchor = anchor {
                UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: anchor), forKey: "anchor")
            }

            guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                completion(.success(.noNewWorkouts))
                return
            }
        
            if let runs = self.runningWorkouts(from: workouts) {
                self.firebaseManager.save(entry: .runs(runs)) { result in
                    switch result {
                    case .success:
                        completion(.success(.saved))
                    case .failure(let error):
                        completion(.failure(.generic(error.localizedDescription)))
                    }
                }
            } else {
                completion(.success(.noNewWorkouts))
            }
        }

        self.healthStore.execute(anchorQuery)
    }

    private func runningWorkouts(from workouts: [HKWorkout]) -> [RunningWorkout]? {
        guard self.savedAnchor != nil else { return nil }
        return workouts.compactMap {
            self.run(from: $0)
        }
    }
    
    private func run(from workout: HKWorkout) -> RunningWorkout {
        return RunningWorkout(
            id: workout.uuid,
            start: workout.startDate,
            end: workout.endDate,
            duration: workout.duration,
            totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
            totalDistance: workout.totalDistance?.doubleValue(for: .mile()).inKm
        )
    }
}

extension HealthKitManager: HealthKitManagerProtocol {
    func requestHealthKitPermissions(completion: @escaping (Result<Void, AppError>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let types = HealthConfiguration.quantityTypes()
        healthStore.requestAuthorization(toShare: nil, read: types) { isPermissionViewShown, error in
            guard error == nil else {
                completion(.failure(.apiError))
                return
            }

            // do not forget to handle authorization status later
            UserDefaults.standard.set(true, forKey: "hasPermissions")
            UserDefaults.standard.set(true, forKey: "hasLoadedAlready")
            completion(.success(()))
        }
    }

    func observeAndSaveWorkouts(completion: @escaping (Result<RunningCompletion, AppError>) -> Void) {
        guard AppDefaults.hasPermissions else {
            completion(.failure(.noHealthKitPermissions))
            return
        }

        saveRuns { result in
            completion(result)
        }
    }

    func getWorkout(for id: UUID, completion: @escaping (HKWorkout) -> Void) {
        let workoutPredicate = HKQuery.predicateForObject(with: id)

        let workoutQuery = HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredicate, limit: 1, sortDescriptors: nil) { query, data, error in
            guard let workout = data?.first as? HKWorkout else {
                print("Workout not found")
                return
            }
            completion(workout)
        }

        self.healthStore.execute(workoutQuery)
    }
    
    func getRoutesRawData(for workout: HKWorkout, completion: @escaping ([HKWorkoutRoute]) -> Void) {
        let routePredicate = HKQuery.predicateForObjects(from: workout)
        let routeQuery = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(), predicate: routePredicate, limit: 0, sortDescriptors: nil) { query, data, error in
            guard let routes = data as? [HKWorkoutRoute] else {
                print("Route for workout not found - might be in Healthkit from Nike running that doesn't share locations")
                return
            }
            completion(routes)
        }
        
        self.healthStore.execute(routeQuery)
    }

    func getWorkoutRoutes(for routes: [HKWorkoutRoute], completion: @escaping ([CLLocation]) -> Void) {
        var locations = [CLLocation]()

        routes.forEach { route in
            let locationQuery = HKWorkoutRouteQuery(route: route) { routeQuery, data, done, error in
                guard let data = data else { return }
                locations.append(contentsOf: data)
                if done {
                    completion(locations)
                }
            }

            self.healthStore.execute(locationQuery)
        }
    }
}

extension HealthKitManager: HealthKitManagerExtendedProtocol {
    func getWorkoutRoute(for workoutId: UUID, completion: @escaping (Result<[CLLocation], AppError>) -> Void) {
        getWorkout(for: workoutId) { [weak self] workout in
            self?.getRoutesRawData(for: workout) { [weak self] rawData in
                self?.getWorkoutRoutes(for: rawData) { locations in
                    completion(.success(locations))
                }
            }
        }
    }
}
