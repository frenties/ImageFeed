import UIKit
import os

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc:AuthViewController)
}

final class AuthViewController: UIViewController {
    @IBOutlet private var loginButton: UIButton!
    weak var delegate: AuthViewControllerDelegate?
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.imagefeed",
        category: "Authentication"
    )
    
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }

        guard let webViewViewController = segue.destination as? WebViewViewController else {
            assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
            return
        }

        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)

        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.delegate = self
    }

    
    func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named:"nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named:"ypBlack")
    }
    
    private func showAlertError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchAuthToken(with: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let token):
                self.tokenStorage.token = token
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                self.logger.error("Authentication failed: \(error.localizedDescription, privacy: .public)")
                self.showAlertError()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}

