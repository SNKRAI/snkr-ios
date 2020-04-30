import MapKit
import HealthKit

protocol WorkoutDetailViewModelProtocol: class {
    func getWorkoutRoute(for uuid: UUID)
}

final class WorkoutDetailViewModel: ObservableObject {
    var healthKitManager: HealthKitManagerExtendedProtocol
    @Published var locations = [CLLocation]()

    init(healthKitManager: HealthKitManagerExtendedProtocol) {
        self.healthKitManager = healthKitManager
    }
}

extension WorkoutDetailViewModel: WorkoutDetailViewModelProtocol {
    func getWorkoutRoute(for uuid: UUID) {
        healthKitManager.getWorkoutRoute(for: uuid) { [weak self] result in
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
