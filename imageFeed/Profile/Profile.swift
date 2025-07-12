import Foundation

struct Profile {
    let username: String
    let name: String
    var loginName: String { "@\(username)" }
    let bio: String
}
