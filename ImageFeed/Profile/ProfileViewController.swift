import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var animationLayers = Set<CALayer>()
    
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
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(gradient)
        avatarImageView.layer.addSublayer(gradient)
        
        
        let nameGradient = CAGradientLayer()
        nameGradient.frame = CGRect(origin: .zero, size: CGSize(width: 223, height: 28))
        nameGradient.locations = [0, 0.1, 0.3]
        nameGradient.colors = gradient.colors
        nameGradient.startPoint = gradient.startPoint
        nameGradient.endPoint = gradient.endPoint
        nameGradient.cornerRadius = 14
        nameGradient.masksToBounds = true
        nameGradient.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(nameGradient)
        nameLabel.layer.addSublayer(nameGradient)
        
        let loginGradient = CAGradientLayer()
        loginGradient.frame = CGRect(origin: .zero, size: CGSize(width: 89, height: 18))
        loginGradient.locations = [0, 0.1, 0.3]
        loginGradient.colors = gradient.colors
        loginGradient.startPoint = gradient.startPoint
        loginGradient.endPoint = gradient.endPoint
        loginGradient.cornerRadius = 9
        loginGradient.masksToBounds = true
        loginGradient.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(loginGradient)
        userName.layer.addSublayer(loginGradient)
        
        let bioGradient = CAGradientLayer()
        bioGradient.frame = CGRect(origin: .zero, size: CGSize(width: 67, height: 18))
        bioGradient.locations = [0, 0.1, 0.3]
        bioGradient.colors = gradient.colors
        bioGradient.startPoint = gradient.startPoint
        bioGradient.endPoint = gradient.endPoint
        bioGradient.cornerRadius = 9
        bioGradient.masksToBounds = true
        bioGradient.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(bioGradient)
        bioLabel.layer.addSublayer(bioGradient)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: ProfileImageService.shared,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
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
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .avatar)
            
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                break
            case .failure:
                self.avatarImageView.image = UIImage(resource: .avatar)
            }
            self.animationLayers.forEach { layer in
                layer.removeFromSuperlayer()
            }
            self.animationLayers.removeAll()
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name
        loginNameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
    }
    
    @objc
    private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверен, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            
            ProfileLogoutService.shared.logout()
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first
            else {
                return
            }
            
            let splashViewController = SplashViewController()
            
            window.rootViewController = splashViewController
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
}

