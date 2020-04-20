import Foundation
import HealthKit
import MapKit

final class HealthKitManager {
    private let healthStore = HKHealthStore()
    private var locations = [CLLocation]()
    private var savedAnchor: HKQueryAnchor?
    private let firebaseManager: FirebaseSaverProtocol = FirebaseManager()
    private let notificationCenter: NotificationManagerProtocol = NotificationManager()

    func getRunningWorkouts(completion: @escaping (Result<[Run], AppError>) -> Void) {
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
            let runs = workouts.compactMap { Run(workout: $0) }
            completion(.success(runs))
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
                print("@@@NO NEW WORKOUTS")
                completion(.success(.noNewWorkouts))
                return
            }
        
            if let runs = self.runningWorkouts(from: workouts) {
                self.firebaseManager.save(entry: .runs(runs)) { result in
                    switch result {
                    case .success:
                        completion(.success(.saved))
                    case .failure(let error):
                        completion(.failure(error))
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
            start: workout.startDate,
            end: workout.endDate,
            duration: workout.duration,
            totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
            totalDistance: workout.totalDistance?.doubleValue(for: .mile())
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
}

extension HealthKitManager: HealthKitManagerExtendedProtocol {
    func getWorkoutRoute(for workout: HKWorkout, completion: @escaping (Result<[CLLocation], AppError>) -> Void) {
        let type = HKSeriesType.workoutRoute()
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)

        let workoutQuery = HKSampleQuery(sampleType: type, predicate: workoutPredicate, limit: 0, sortDescriptors: nil) { [weak self] query, data, error  in
            guard let self = self, let routes = data as? [HKWorkoutRoute] else { return }
                        
            routes.forEach { route in
                let locationQuery = HKWorkoutRouteQuery(route: route) { [weak self] routeQuery, data, done, error in
                    guard let self = self, let data = data else { return }
                    self.locations.append(contentsOf: data)
                    if done {
                        completion(.success(self.locations))
                    }
                }
                
                self.healthStore.execute(locationQuery)
            }
        }
        
        self.healthStore.execute(workoutQuery)
    }
}
