import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    private func makeOAuthTokenRequest(code:String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Error: Invalid URLComponents")
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
            print("Error: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchAuthToken(with code: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { result  in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    completion(.success(responseBody.accessToken))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

extension URLSession {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulFillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(error)
                fulFillCompletion(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse,
               let data = data {
                
                let statusCode = response.statusCode
                
                if (200 ..< 300).contains(statusCode) {
                    fulFillCompletion(.success(data))
                } else {
                    let serverError = URLError(.badServerResponse)
                    print(serverError)
                    fulFillCompletion(.failure(serverError))
                    
                }
            } else {
                let serverError = URLError(.badServerResponse)
                print(serverError)
                fulFillCompletion(.failure(serverError))
            }
        }
        return task
    }
}

