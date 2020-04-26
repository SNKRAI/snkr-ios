import Combine
import SwiftUI

class MySneakersViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<MySneakersViewModel, Never>()
    private let fetchService: FetchServiceProtocol
    private let saveService: FirebaseManager

    @Published var state: SneakerState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        fetchService: FetchServiceProtocol = FetchService(),
        saveService: FirebaseManager = FirebaseManager()
    ) {
        self.fetchService = fetchService
        self.saveService = saveService
    }

    func fetchMySneakers() {
        let keys = Keys(collection: .userId, document: .sneakers)
        fetchService.fetch(with: keys) { [weak self] state in
            self?.state = state
        }
    }

    func save(workout: RunningWorkoutContainer, for sneaker: SneakerContainer, completion: @escaping (Swift.Result<Void, FetchError>) -> Void) {
        saveService.save(entry: .workout(workout, sneaker)) { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                let keys = Keys(collection: .userId, document: .pendingWorkouts)
                self.fetchService.delete(for: keys, containerId: workout.id) { result in
                    completion(result)
                }
            }
        }
    }

    func delete(at indexSet: IndexSet, in container: [SneakerContainer]) {
        guard let index = Array(indexSet).first else { return }
        var saved = container
        let keys = Keys(collection: .userId, document: .sneakers)
        fetchService.delete(for: keys, containerId: container[index].id) { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                if let index = container.firstIndex(of: saved[index]) {
                    saved.remove(at: index)
                    self.state = saved.isEmpty ? .empty : .fetched(saved)
                }
            }
        }
    }
}
