@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var photosCount: Int = 0
    
    var viewDidLoadCallsCount = 0
    var willDisplayCellCalled = false
    var cellLikeButtonTappedCalled = false
    
    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }
    
    func photo(at index: Int) -> Photo {
        return Photo(
            id: "1",
            size: .zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }
    
    func calculateCellHeight(at index: Int, tableViewWidth: Double) -> Double {
        return 200.0
    }
    
    func formatPhotoDate(at index: Int) -> String? {
        return "14 августа 2026"
    }
    
    func willDisplayCell(at index: Int) {
        willDisplayCellCalled = true
    }
    
    func cellLikeButtonTapped(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        cellLikeButtonTappedCalled = true
    }
}

