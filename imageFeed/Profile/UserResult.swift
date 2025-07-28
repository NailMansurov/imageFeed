import Foundation

struct ProfileImage: Codable {
    let small: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}

