import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol! { get set }
    func updateProfileDetails(name: String, loginName: String, bio: String?)
    func updateAvatar(with url: URL)
    func showLogoutAlert()
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        updateProfileDetails()
        observeAvatarChanges()
    }
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        
        view?.updateProfileDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
    
    private func observeAvatarChanges() {
        updateAvatar()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: profileImageService,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }
    }
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        view?.updateAvatar(with: url)
    }
}

