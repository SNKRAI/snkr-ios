import UIKit

final class LoginViewController: UIViewController {
    
    private var loginButtons: [LoginButton]
    private var userService: FirebaseUserServiceProtocol
    private var trackingService: TrackingProtocol
    
    init(
        with loginButtons: [LoginButton],
        userService: FirebaseUserServiceProtocol = FirebaseUserService(),
        trackingService: TrackingProtocol = TrackingService()
    ) {
        self.loginButtons = loginButtons
        self.userService = userService
        self.trackingService = trackingService
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(stack)
        
        loginButtons.forEach { button in
            stack.addArrangedSubview(loginButton)
            loginButton.setTitle(button.title, for: .normal)
            loginButton.backgroundColor = button.color
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.heightAnchor.constraint(equalToConstant: 55),
            stack.widthAnchor.constraint(equalToConstant: 200),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func loginAction() {
        loginButtons.forEach { button in
            switch button.method {
            case .google:
                self.trackingService.track(event: .loginPressedTest)
                userService.signInWithGoogle(viewController: self)
            }
        }
    }

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill

        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
