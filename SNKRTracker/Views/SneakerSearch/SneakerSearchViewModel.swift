import SwiftUI
import Combine

class SneakerSearchViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<SneakerSearchViewModel, Error>()
    
    private let fetchService: FetchService
    private let saverService: FirebaseManager

    @Published var state: SneakerState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }
    
    init(
        fetchService: FetchService = FetchService(),
        saverService: FirebaseManager = FirebaseManager()
    ) {
        self.fetchService = fetchService
        self.saverService = saverService
        fetchSneakers()
    }
    
    func fetchSneakers() {
        let keys = Keys(collection: .allSneakers, document: .models)
        fetchService.fetch(with: keys) { [weak self] state in
            self?.state = state
        }
    }
    
    func add(_ sneaker: Sneaker) {
        saverService.save(entry: .sneaker(sneaker)) { [weak self] result in
            if case .success = result {
                print("success")
            }
        }
    }
}
