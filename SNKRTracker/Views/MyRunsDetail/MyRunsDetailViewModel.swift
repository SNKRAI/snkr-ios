import MapKit
import HealthKit

protocol MyRunsDetailViewModelProtocol: class {
    func getWorkoutRoute(for workout: HKWorkout)
}

final class MyRunsDetailViewModel: ObservableObject {
    var healthKitManager: HealthKitManagerExtendedProtocol
    @Published var locations = [CLLocation]()

    init(healthKitManager: HealthKitManagerExtendedProtocol) {
        self.healthKitManager = healthKitManager
    }
}

extension MyRunsDetailViewModel: MyRunsDetailViewModelProtocol {
    func getWorkoutRoute(for workout: HKWorkout) {
        healthKitManager.getWorkoutRoute(for: workout) { [weak self] result in
            switch result {
            case .success(let locations):
                DispatchQueue.main.async {
                    self?.locations = locations
                }
            case .failure(let error):
                print("show error:", error)
            }
        }
    }
}
