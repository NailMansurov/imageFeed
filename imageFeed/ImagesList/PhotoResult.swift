import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let isLiked: Bool
    let description: String?
    let imageURL: UrlsResult
}
