import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
    func authTokenRequest(code: String) -> URLRequest?
}

final class AuthHelper: AuthHelperProtocol {
    
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil}
        return URLRequest(url:url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        guard
              let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" })
          else {
              return nil
          }

          return codeItem.value
      }
    
    func authTokenRequest(code: String) -> URLRequest? {
        guard var url = URL(string:"https://unsplash.com/oauth/token") else {
            return nil
        }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            var urlComponents = URLComponents()
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: configuration.accessKey),
                URLQueryItem(name: "client_secret", value: configuration.secretKey),
                URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
            
            if let queryString = urlComponents.query {
                request.httpBody = queryString.data(using: .utf8)
            }
            
            return request
        }
    }
