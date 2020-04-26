import Foundation
import HealthKit

struct Sneaker: Identifiable, Hashable {
    var id = UUID()
    let company: String
    let model: String
    let workouts: [String: HKWorkout]?
}

struct Container<T: Hashable>: Identifiable, Hashable {
    let id: String
    let data: T
}

/// Containers
typealias SneakerContainer = Container<Sneaker>
typealias RunningWorkoutContainer = Container<HKWorkout>

/// Loadable States
typealias SneakerState = LoadableState<[SneakerContainer]>
typealias RunninWorkoutState = LoadableState<[RunningWorkoutContainer]>

/// Custom States
typealias MainState = FetchState<[RunningWorkoutContainer], [SneakerContainer]>
