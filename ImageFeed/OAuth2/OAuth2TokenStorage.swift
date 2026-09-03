import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let tokenKey = "OAuth2AccessToken"
    
    init() {}
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
