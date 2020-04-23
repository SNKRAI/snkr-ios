import Combine

final class MyRunsViewModel: ObservableObject {

    private let changeObserver = PassthroughSubject<MyRunsViewModel, Never>()
    private let healthKitManager: HealthKitManagerProtocol

    private var fetchService: FetchServiceProtocol

    @Published var state: MainState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        fetchService: FetchServiceProtocol = FetchService(),
        healthKitManager: HealthKitManagerProtocol = HealthKitManager()
    ) {
        self.fetchService = fetchService
        self.healthKitManager = healthKitManager
        
        fetch()
    }

    func append(sneaker: SneakerContainer) {
        fetchService.sneakerContainer.append(sneaker)
        self.state = .fetched(
            fetchService.runninWorkoutContainer,
            fetchService.sneakerContainer
        )
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
        guard let collection = Collection(rawValue: "userId") else { return }
        fetchService.fetchAllDocuments(collection: collection) { [weak self] fetchState in
            self?.state = fetchState
        }
    }
}
