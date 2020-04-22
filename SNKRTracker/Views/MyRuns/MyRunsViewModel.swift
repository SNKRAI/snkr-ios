import Combine

final class MyRunsViewModel: ObservableObject {

    private let changeObserver = PassthroughSubject<MyRunsViewModel, Never>()
    private let healthKitManager: HealthKitManagerProtocol

    private let fetchService: FetchService

    @Published var state: RunninWorkoutState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        fetchService: FetchService = FetchService(
        keys: Keys(collection: .userId,
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
    
    func sort(runs: [RunningWorkoutContainer]) -> (pending: [RunningWorkoutContainer], past: [SneakerWithWorkouts]) {
        
        var pending = [RunningWorkoutContainer]()
        var locals = [LocalSneaker]()
        
        runs.forEach { run in
            if let sneaker = run.data.sneaker {
                let local = LocalSneaker(
                    id: sneaker.id,
                    company: sneaker.company,
                    model: sneaker.model,
                    workout: LocalWorkout(
                        id: run.data.id,
                        start: run.data.start,
                        end: run.data.end,
                        duration: run.data.duration,
                        totalEnergyBurned: run.data.totalEnergyBurned,
                        totalDistance: run.data.totalDistance
                    )
                )


                locals.append(local)
            } else {
                pending.append(run)
            }
        }
        
        return (pending, sort(past: locals))
    }
    
    private func sort(past: [LocalSneaker]) -> [SneakerWithWorkouts] {
        var workoutSneakers = [SneakerWithWorkouts]()
        
        let duplicatedSneakers = Dictionary(grouping: past, by: { $0.id }).compactMap { $0.value }
        duplicatedSneakers.forEach { sneakers in
            guard let sneaker = sneakers.first else { return }
            workoutSneakers.append(
                SneakerWithWorkouts(id: sneaker.id,
                               company: sneaker.company,
                               model: sneaker.model,
                               workouts: sneakers.compactMap { $0.workout } )
            )
        }
                
        return workoutSneakers
    }
    

    private func fetchRunningWorkouts() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
}
