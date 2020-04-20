import Foundation
import HealthKit
import MapKit

protocol HealthKitManagerExtendedProtocol: class {
    func getWorkoutRoute(for workout: HKWorkout, completion: @escaping (Result<[CLLocation], AppError>) -> Void)
}

protocol HealthKitManagerProtocol: class {
    func requestHealthKitPermissions(completion: @escaping (Result<Void, AppError>) -> Void)
    func observeAndSaveWorkouts(completion: @escaping (Result<RunningCompletion, AppError>) -> Void)
}

enum RunningCompletion {
    case saved, noNewWorkouts
}
