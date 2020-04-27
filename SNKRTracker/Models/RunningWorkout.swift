import Foundation
import HealthKit

struct Run: Identifiable {
    var id = UUID()
    let workout: HKWorkout
}
