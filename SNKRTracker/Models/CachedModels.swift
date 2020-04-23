import Foundation

/// Models for performing sorting localy
struct LocalSneaker: Hashable {
    var id: UUID
    let company: String
    let model: String
    let workout: LocalWorkout
}

struct LocalWorkout: Hashable {
    var id: UUID
    let start: Date
    let end: Date
    let duration: TimeInterval
    let totalEnergyBurned: Double?
    let totalDistance: Double?
}

struct SneakerWithWorkouts: Hashable, Identifiable {
    var id: UUID
    let company: String
    let model: String
    let workouts: [LocalWorkout]
}
