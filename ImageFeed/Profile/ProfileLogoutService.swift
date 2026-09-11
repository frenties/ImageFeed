import Foundation
import UIKit
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    static let didLogoutNotification = Notification.Name("ProfileLogoutService")
    private init() {}
    
    func logout() {
        cleanCookies()
        cleanStorageData()
        
        NotificationCenter.default.post(name: ProfileLogoutService.didLogoutNotification, object: nil)
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanStorageData() {
        
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatar()
    }
}

