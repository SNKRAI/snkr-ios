import Foundation
import HealthKit

struct Run: Identifiable {
    var id = UUID()
    let workout: HKWorkout
}

struct RunningWorkout: Identifiable, Codable, Hashable {
    var id = UUID()
    let start: Date
    let end: Date
    let duration: TimeInterval
    let totalEnergyBurned: Double?
    let totalDistance: Double?
    let hasSneakers = false
}
