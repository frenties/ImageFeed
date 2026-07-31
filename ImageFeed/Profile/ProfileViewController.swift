import UIKit

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var userNameLabel: UILabel?
    private var bioLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - profileImage
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 76).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        
        // MARK: - nameLabel
        let nameLabel = UILabel()
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.nameLabel = nameLabel
        
        // MARK: - userName
        let userName = UILabel()
        userName.text = "@ekaterina_nov"
        userName.textColor = .ypGrayIOS
        userName.font = UIFont.systemFont(ofSize: 13, weight:.regular)
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        
        userName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        userName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant:8).isActive = true
        self.userNameLabel = userName
        
        // MARK: - bioLabel
        let bioLabel = UILabel()
        bioLabel.text = "Hello, world!"
        bioLabel.textColor = .ypWhiteIOS
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight:.regular)
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        
        bioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        bioLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant:8).isActive = true
        
        self.bioLabel = bioLabel
        
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        
        exitButton.tintColor = .ypRedIOS
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
                exitButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapButton() {
        nameLabel?.removeFromSuperview()
        userNameLabel?.removeFromSuperview()
        bioLabel?.removeFromSuperview()
        
        nameLabel = nil
        userNameLabel = nil
        bioLabel = nil
    }
}
