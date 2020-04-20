import Firebase
import FirebaseAuth
import GoogleSignIn
import Combine

protocol FirebaseUserServiceProtocol {
    func signInWithGoogle(viewController: UIViewController)
    func googleLogin(authentication: GIDAuthentication, completion: @escaping (Swift.Result<User, Error>) -> Void)
    func logout()
}

final class FirebaseUserService: NSObject, ObservableObject {
    private var changeHandle: AuthStateDidChangeListenerHandle?
    
    var changeObserver = PassthroughSubject<FirebaseUserService, Never>()
    @Published var state: MainViewState = .loading {
        didSet {
            changeObserver.send(self)
        }
    }

    override init() {
        super.init()

        self.changeHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let user = user {
                self.state = .loggedIn(user)                
            } else {
                if AppDefaults.hasLoadedAlready {
                    self.state = .notLoggedIn
                } else {
                    self.state = .firstLaunch
                }
            }
        }
    }

    internal func googleLogin(authentication: GIDAuthentication, completion: @escaping (Swift.Result<User, Error>) -> Void) {
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else { return }
            completion(.success(user))
        }
    }
}

// MARK: - FirebaseUserServiceProtocol
extension FirebaseUserService: FirebaseUserServiceProtocol {
    func signInWithGoogle(viewController: UIViewController) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        GIDSignIn.sharedInstance().signIn()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.state = .notLoggedIn
        } catch let error {
            assertionFailure("Error while logging out \(error.localizedDescription)")
        }
    }
}

// MARK: - GIDSignInDelegate
extension FirebaseUserService: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard error == nil else {
            return print("error or user has canceled login")
        }
    
        guard let authentication = user.authentication else { return }
        self.googleLogin(authentication: authentication) { result in
            switch result {
            case .success(let user):
                self.state = .loggedIn(user)
            case .failure:
                self.state = .notLoggedIn
            }
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.state = .notLoggedIn
    }
}

enum MainViewState {
    case loading
    case loggedIn(User)
    case notLoggedIn
    case firstLaunch
}
