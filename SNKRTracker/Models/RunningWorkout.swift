import Foundation
import HealthKit

struct Run: Identifiable {
    var id = UUID()
    let workout: HKWorkout
}

struct Container: Codable {
    let workouts: [RunningWorkout]
}

struct RunningWorkout: Identifiable, Codable {
    var id = UUID()
    let start: Date
    let end: Date
    let duration: TimeInterval
    let totalEnergyBurned: Double?
    let totalDistance: Double?
    let hasSneakers = false
}
