import Foundation
import HealthKit

final class HealthConfiguration {
    static func quantityTypes() -> Set<HKObjectType> {
        var readData: Set<HKObjectType> = [.workoutType(), HKSeriesType.workoutRoute()]

        if let distanceWalkingRunning = distanceWalkingRunning {
            readData.insert(distanceWalkingRunning)
        }

        if let heartRate = quantityType(.heartRate) {
            readData.insert(heartRate)
        }

        return readData
    }
    
    static var distanceWalkingRunning: HKObjectType? {
        quantityType(.distanceWalkingRunning)
    }
    
    static var runningPredicate: NSCompoundPredicate {
         let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
         return NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate])
    }
    
    private static func quantityType(_ identifier: HKQuantityTypeIdentifier) -> HKQuantityType? {
        return HKSampleType.quantityType(forIdentifier: identifier) ?? nil
    }
}
