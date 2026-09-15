import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListService
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    var photosCount: Int {
        return photos.count
    }
    
    init(imagesListService: ImagesListService = ImagesListService(urlSession: URLSession.shared)) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updatePhotos()
        }
        
        updatePhotos()
        if photos.isEmpty {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func calculateCellHeight(at index: Int, tableViewWidth: Double) -> Double {
        let photo = photos[index]
        let imageViewWidth = tableViewWidth - 32
        
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        
        if imageWidth == 0 { return 0 }
        return (imageHeight / imageWidth) * imageViewWidth + 8
    }
    
    func formatPhotoDate(at index: Int) -> String? {
        guard let date = photos[index].createdAt else { return "" }
        return dateFormatter.string(from: date)
    }
    
    func willDisplayCell(at index: Int) {
        if index + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    func cellLikeButtonTapped(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let photo = photos[index]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let updatedPhoto = self.photos[index]
                completion(.success(updatedPhoto.isLiked))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}
