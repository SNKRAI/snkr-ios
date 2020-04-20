import Combine

class MySneakersViewModel: ObservableObject {
    private let changeObserver = PassthroughSubject<MySneakersViewModel, Never>()
    private let fetchService: FetchService<Sneaker>

    @Published var state: LoadableState<[Sneaker]> = .loading {
        didSet {
            changeObserver.send(self)
        }
    }
    
     init(
        fetchService: FetchService<Sneaker> = FetchService(
        key: Key(collection: .userId,
                 document: .sneakers))
     ) {
        self.fetchService = fetchService
        
        fetchMySneakers()
    }
    
    func fetchMySneakers() {
        fetchService.fetch { [weak self] state in
            self?.state = state
        }
    }
}
