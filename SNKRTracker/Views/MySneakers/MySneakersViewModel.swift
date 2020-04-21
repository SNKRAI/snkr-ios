import Combine

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
    
    func delete(sneaker: Container<Sneaker>) {
        fetchService.delete(sneaker: sneaker) { result in
            switch result {
            case .success:
                print("deleted")
            case .failure(let error):
                print("error")
            }
        }
    }
}
