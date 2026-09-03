import UIKit

final class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .appIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate( [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            showAuthViewController()
        }
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? UINavigationController,
              
                let authViewController = navigationController.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController from Storyboard")
            return
        }
        
        authViewController.delegate = self
        
        navigationController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка получения профиля: \(error.localizedDescription)")
            }
            self.showAuthViewController()
        }
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
                    assertionFailure("Invalid window configuration")
                    return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let token = self.storage.token {
                self.fetchProfile(token)
            } else {
                print("Error:no token in Keychain")
            }
            
        }
    }
}
