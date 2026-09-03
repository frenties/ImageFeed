import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let avatarImageView: UIImageView = {
        let profileImage = UIImage(resource: .avatar)
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        view.addSubview(avatarImageView)
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 76).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        self.nameLabel = nameLabel
        
        let userName = UILabel()
        userName.textColor = .ypGrayIOS
        userName.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        
        userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        self.loginNameLabel = userName
        
        let bioLabel = UILabel()
        bioLabel.textColor = .ypWhiteIOS
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        
        bioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        bioLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
        self.descriptionLabel = bioLabel
        
        let exitButtonImage = UIImage(resource: .exit)
        let exitButton = UIButton.systemButton(
            with: exitButtonImage,
            target: self,
            action: #selector(self.didTapButton)
        )
        exitButton.tintColor = .ypRedIOS
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
    
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: ProfileImageService.shared,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                print("=== [Уведомление] Сигнал о новой аватарке получен в контроллере! ===")
                self.updateAvatar()
            }
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(resource: .avatar),
                                    options: [.cacheOriginalImage]
        )
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name
        loginNameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
    }
    
    @objc
    private func didTapButton() {
        
    }
}

