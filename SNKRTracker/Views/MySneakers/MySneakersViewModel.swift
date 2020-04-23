import Combine
import SwiftUI

class MySneakersViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<MySneakersViewModel, Never>()
    private let fetchService: FetchService
    private let saveService: FirebaseManager
    
    @Published var state: SneakerState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    init(
        fetchService: FetchService = FetchService(
        keys: Keys(collection: .userId,
                 document: .sneakers)),
        saveService: FirebaseManager = FirebaseManager()
    ) {
        self.fetchService = fetchService
        self.saveService = saveService
    }
    
    func fetchMySneakers() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
    
    func rowSelected(with workout: RunningWorkout) {
        print("SAVE:", workout.sneaker, "FOR:", workout.totalDistance!)
    }
    
    func delete(at indexSet: IndexSet, in container: [SneakerContainer]) {
        guard let index = Array(indexSet).first else { return }
        var saved = container                
        fetchService.delete(containerId: container[index].id) { [weak self] result in
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
