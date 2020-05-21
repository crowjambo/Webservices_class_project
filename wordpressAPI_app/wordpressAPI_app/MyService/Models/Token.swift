import Foundation

struct Token: Decodable {
    var token: String?
    var email: String?
    var nickname: String?
    var displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case email = "user_email"
        case nickname = "user_nicename"
        case displayName = "user_display_name"
    }
}
