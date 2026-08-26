import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc:AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController =
                    segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }

            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named:"nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named:"ypBlack")
    }
    
    private func fetchAuthToken(with code: String) {
        oauth2Service.fetchAuthToken(with: code) { result in
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        
        oauth2Service.fetchAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                self.tokenStorage.token = token
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("Ошибка авторизации: \(error.localizedDescription)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}

