import HealthKit

extension HKWorkout {
    func toJson() -> [String: Any] {
        return [
            "duration": duration,
            "startDate": startDate,
            "endDate": endDate,
            "totalDistance": totalDistance?.doubleValue(for: .mile()),
            "totalEnergyBurned": totalEnergyBurned?.doubleValue(for: .kilocalorie()),
            "metadata": metadata
        ]
    }
}
