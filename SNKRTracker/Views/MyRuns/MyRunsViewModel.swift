import Combine

final class MyRunsViewModel: ObservableObject {
    
    private let changeObserver = PassthroughSubject<MyRunsViewModel, Never>()
    private let healthKitManager: HealthKitManagerProtocol
     
    private let fetchService: FetchService<RunningWorkout>

    @Published var state: LoadableState<[RunningWorkout]> = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        fetchService: FetchService<RunningWorkout> = FetchService(
        key: Key(collection: .userId,
                 document: .workouts)),
        healthKitManager: HealthKitManagerProtocol = HealthKitManager()
    ) {
        self.fetchService = fetchService
        self.healthKitManager = healthKitManager
        
        fetch()
    }
    
    func fetch() {
        healthKitManager.observeAndSaveWorkouts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchRunningWorkouts()
            case .failure(let error):
                if case .noHealthKitPermissions = error {
                    self.healthKitManager.requestHealthKitPermissions { [weak self] result in
                        if case .success = result {
                            self?.fetchRunningWorkouts()
                        }
                    }
                    
                    return
                }
    
                self.state = .error(.reason(error.localizedDescription))
            }
        }
    }
    
    private func fetchRunningWorkouts() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
}
