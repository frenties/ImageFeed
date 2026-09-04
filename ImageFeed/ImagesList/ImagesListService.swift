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
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    func fetchPhotosNextPage() {
        
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = URL(string: "https://unsplash.com\(nextPage)") else { return }
        var request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data, error == nil else {
                
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            let decoder = JSONDecoder()
            
            guard let photoResults = try? decoder.decode([PhotoResult].self, from: data) else {
                DispatchQueue.main.async { self.currentTask = nil }
                return
            }
            
            let dateFormatter = ISO8601DateFormatter()
            
            let newPhotos = photoResults.map { result in
                Photo(id: result.id,
                      size: CGSize(width: result.width, height: result.height),
                      createdAt: dateFormatter.date(from:result.created_at ?? ""),
                      welcomeDescription: result.description,
                      thumbImageURL: result.urls.thumb,
                      largeImageURL: result.urls.full,
                      isLiked: result.liked_by_user)
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
}
