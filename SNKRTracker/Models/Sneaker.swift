import Foundation

struct Sneaker: Identifiable, Codable, Hashable {
    var id = UUID()
    let company: String
    let model: String
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

typealias SneakerState = LoadableState<[SneakerContainer]>
typealias RunninWorkoutState = LoadableState<[RunningWorkoutContainer]>

typealias SneakerContainer = Container<Sneaker>
typealias RunningWorkoutContainer = Container<RunningWorkout>
