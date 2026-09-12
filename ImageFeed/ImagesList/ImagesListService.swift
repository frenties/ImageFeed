import UIKit

final class ImagesListService {
    // MARK: - Public Properties
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    
    // MARK: - Private Properties
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    private let urlSession: URLSession
    
    // MARK: - Initializer
    init(urlSession: URLSession) {
        self.urlSession = urlSession
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearPhotosFromNotification),
            name: ProfileLogoutService.didLogoutNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let request = makePhotosRequest(page: nextPage)
        
        let task = urlSession.dataTask(with: request) {
            [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
                print("[fetchPhotosNextPage ImagesListService]: NetworkError \(error.localizedDescription) for page \(nextPage)")
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            guard let data = data else {
                print("[fetchPhotosNextPage ImagesListService]: DataError No data received for page \(nextPage)")
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            guard let photoResults =  try? self.decodePhotos(from: data) else {
                print("[fetchPhotosNextPage ImagesListService]: DecodingError - Failed to decode PhotoResult for page \(nextPage)")
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            let newPhotos = self.mapPhotos(photoResults)
            
            DispatchQueue.main.async {
                self.updatePhotos(newPhotos, page: nextPage)
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makePhotosRequest(page: Int) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)") else {
            fatalError("Invalid URL for page \(page)")
        }
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
    
    private func decodePhotos(from data: Data) throws -> [PhotoResult] {
        let decoder = JSONDecoder()
        return try decoder.decode([PhotoResult].self, from: data)
    }
    
    private func mapPhotos(_ results: [PhotoResult]) -> [Photo] {
        return results.map { result in
            Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: self.dateFormatter.date(from: result.createdAt ?? ""),
                welcomeDescription: result.description,
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                isLiked: result.isLiked
            )
        }
    }
    
    private func updatePhotos(_ photos: [Photo], page: Int) {
        self.photos.append(contentsOf: photos)
        self.lastLoadedPage = page
        self.currentTask = nil
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
        )
    }
    
    // MARK: - Public Methods
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )
        
        let task = urlSession.dataTask(with: request) {
            [weak self] _, _, error in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if let error {
                    print("[changeLike ImagesListService]: NetworkError \(error.localizedDescription) for photoId \(photoId)")
                    completion(.failure(error))
                    return
                }
                
                if let index = self.photos.firstIndex(where: {
                    $0.id == photoId
                }) {
                    let photo = self.photos[index]
                    
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: isLike
                    )
                    
                    self.photos = self.photos.withReplaced(
                        itemAt: index,
                        newValue: newPhoto
                    )
                }
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func clearPhotos() {
        photos = []
        lastLoadedPage = nil
        currentTask?.cancel()
        currentTask = nil
    }
    
    @objc private func clearPhotosFromNotification() {
        clearPhotos()
    }
}

// MARK: - Array Extension
extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var modifiedArray = self
        modifiedArray[index] = newValue
        return modifiedArray
    }
}
