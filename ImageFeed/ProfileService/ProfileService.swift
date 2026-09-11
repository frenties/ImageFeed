import Foundation
import os

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "ImageFeed",
        category: "ProfileService"
    )
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let profileResult):
                let firstName = profileResult.firstName ?? ""
                let lastName = profileResult.lastName ?? ""
                let name = "\(firstName) \(lastName)"
                
                let profile = Profile(
                    username: profileResult.username ?? "",
                    name: name,
                    loginName: "@\(profileResult.username ?? "")",
                    bio: profileResult.bio
                )
                
                self.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                self.logger.error("[fetchProfile]: NetworkError - Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clearProfile() { profile = nil }
}

