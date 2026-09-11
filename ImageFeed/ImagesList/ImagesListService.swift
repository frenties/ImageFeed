import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    let dateFormatter = ISO8601DateFormatter()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearPhotosFromNotification),
            name: ProfileLogoutService.didLogoutNotification,
            object: nil
        )
    }
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard
            let url = URL(
                string: "https://api.unsplash.com/photos?page=\(nextPage)"
            )
        else { return }
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )
        
        let task = URLSession.shared.dataTask(with: request) {
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
            
            let decoder = JSONDecoder()
            
            guard
                let photoResults = try? decoder.decode(
                    [PhotoResult].self,
                    from: data
                )
            else {
                print("[fetchPhotosNextPage ImagesListService]: DecodingError - Failed to decode PhotoResult for page \(nextPage)")
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            let newPhotos = photoResults.map { result in
                Photo(
                    id: result.id,
                    size: CGSize(width: result.width, height: result.height),
                    createdAt: self.dateFormatter.date(
                        from: result.created_at ?? ""
                    ),
                    welcomeDescription: result.description,
                    thumbImageURL: result.urls.thumb,
                    largeImageURL: result.urls.full,
                    isLiked: result.liked_by_user
                )
            }
            DispatchQueue.main.async {
                self.photos.append(contentsOf: newPhotos)
                
                self.lastLoadedPage = nextPage
                self.currentTask = nil
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )
        
        let task = URLSession.shared.dataTask(with: request) {
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
                        isLiked: !photo.isLiked
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

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var modifiedArray = self
        modifiedArray[index] = newValue
        return modifiedArray
    }
}
