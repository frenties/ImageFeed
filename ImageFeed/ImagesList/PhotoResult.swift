import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let updatedAt: String?
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let isLiked: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case width
        case height
        case color
        case likes
        case description
        case urls
        
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blurHash = "blur_hash"
        case isLiked = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small : String
    let thumb: String
}
