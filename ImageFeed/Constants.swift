import Foundation

enum Constants {
    static let accessKey = "zY98o49IDYc3SVOz86vLi2JdNLUC-J37BNYK3UxPIq8"
    static let secretKey = "6ZXuYQe6e2uIR9dSi7Yp5rOxrooYSGXE1Fhd0USiVJo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
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
