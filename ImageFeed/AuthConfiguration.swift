import Foundation

enum Constants {
    static let accessKey = "zY98o49IDYc3SVOz86vLi2JdNLUC-J37BNYK3UxPIq8"
    static let secretKey = "6ZXuYQe6e2uIR9dSi7Yp5rOxrooYSGXE1Fhd0USiVJo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURLString: Constants.defaultBaseURLString)
    }
}

private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    guard var urlComponents = URLComponents(string:"https://unsplash.com/oauth/token") else {
        return nil
    }
    
    urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: Constants.accessKey),
        URLQueryItem(name: "client_secret", value: Constants.secretKey),
        URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        URLQueryItem(name: "code", value: code),
        URLQueryItem(name: "grant_type", value: "authorization_code")
    ]
    
    guard let authTokenUrl = urlComponents.url else {
        return nil
    }
    
    var request = URLRequest(url: authTokenUrl)
    request.httpMethod = "POST"
    return request
}
