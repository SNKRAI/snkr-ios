import Foundation

struct Sneaker: Identifiable, Codable, Hashable {
    var id = UUID()
    let company: String
    let model: String
    let workouts: [RunningWorkoutContainer]?
}

struct Container<T: Decodable
                  & Encodable
                  & Hashable>: Decodable,
                               Encodable,
                               Identifiable,
                               Hashable {
    let id: String
    let data: T
}

/// Containers
typealias SneakerContainer = Container<Sneaker>
typealias RunningWorkoutContainer = Container<RunningWorkout>

/// Loadable States
typealias SneakerState = LoadableState<[SneakerContainer]>
typealias RunninWorkoutState = LoadableState<[RunningWorkoutContainer]>

/// Custom States
typealias MainState = FetchState<[RunningWorkoutContainer], [SneakerContainer]>
