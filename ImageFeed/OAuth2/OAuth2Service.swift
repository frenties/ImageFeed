import Foundation
import os

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let dataStorage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var authToken: String? {
        get {
            dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    private init() {}
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[makeOAuthTokenRequest]: URLComponentsError - Не удалось создать URLComponents")
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
            print("[makeOAuthTokenRequest]: URLError - Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchAuthToken(with code: String, completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("[fetchAuthToken]: AuthServiceError - Запрос с кодом \(code) уже выполняется")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            self.task = nil
            self.lastCode = nil
            
            switch result {
            case .success(let responseBody):
                self.authToken = responseBody.accessToken
                completion(.success(responseBody.accessToken))
                
            case .failure(let error):
                print("[fetchAuthToken]: NetworkError - Ошибка получения токена: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}

extension URLSession {
    
    private var logger: Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageFeed",
               category: "NetworkCore"
        )
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                self.logger.error("[data]: NetworkError - Ошибка запроса: \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, let data = data {
                let statusCode = response.statusCode
                
                if (200 ..< 300).contains(statusCode) {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let serverError = URLError(.badServerResponse)
                    self.logger.error("[data]: NetworkError - Некорректный статус-код: \(statusCode), URL: \(request.url?.absoluteString ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(serverError))
                }
            } else {
                let serverError = URLError(.badServerResponse)
                self.logger.error("[data]: NetworkError - Пустой ответ сервера или отсутствует HTTPURLResponse")
                fulfillCompletionOnTheMainThread(.failure(serverError))
            }
        }
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let rawDataString = String(data: data, encoding: .utf8) ?? ""
                    self.logger.error("[objectTask]: DecodingDataError - Ошибка декодирования: \(error.localizedDescription), Данные: \(rawDataString)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

