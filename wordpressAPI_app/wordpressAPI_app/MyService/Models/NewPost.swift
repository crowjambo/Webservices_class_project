import Foundation

struct NewPost: Codable {
    var id: Int?
    var title: String?
    var content: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case content = "content"
    }
    
     public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = (try values.decodeIfPresent(WPAPIText.self, forKey: .title))?.rendered
        content = (try values.decodeIfPresent(WPAPIText.self, forKey: .content))?.rendered

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(content, forKey: .content)

    }
}
