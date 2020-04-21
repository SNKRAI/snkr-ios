import Combine
import SwiftUI

class MySneakersViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<MySneakersViewModel, Never>()
    private let fetchService: FetchService
    
    @Published var state: LoadableState<[Container<Sneaker>]> = .loading {
        didSet {
            changeObserver.send(self)
        }
    }
    
     init(
        fetchService: FetchService = FetchService(
        keys: Keys(collection: .userId,
                 document: .sneakers))
     ) {
        self.fetchService = fetchService        
    }
    
    func fetchMySneakers() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
    
    func delete(at indexSet: IndexSet, in container: [Container<Sneaker>]) {
        guard let index = Array(indexSet).first else { return }
        var saved = container                
        fetchService.delete(containerId: container[index].id) { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                if let index = container.firstIndex(of: saved[index]) {
                    saved.remove(at: index)
                    self.state = .fetched(saved)
                }
            }
        }
    }
}
