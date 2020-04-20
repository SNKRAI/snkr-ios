import Combine

class SneakerSearchViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<SneakerSearchViewModel, Error>()
    
    private let fetchService: FetchService<Sneaker>
    
    @Published var state: LoadableState<[Sneaker]> = .loading {
        didSet {
            changeObserver.send(self)
        }
    }
    
    init(
        fetschService: FetchService<Sneaker> = FetchService(
        key: Key(collection: .allSneakers,
                 document: .models))
    ) {
        self.fetchService = fetschService
        fetchSneakers()
    }
    
    func fetchSneakers() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
}
