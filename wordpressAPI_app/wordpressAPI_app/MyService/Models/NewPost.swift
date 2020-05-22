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
    
    func ToTask() -> Task {
        guard
            let id = self.id,
            let title = self.title,
            let content = self.content
            else { return Task(id: 0, title: "failedToLoad", content: "failedToLoad")}
        return Task(id: id, title: title, content: content)
    }
    
}


public struct WPAPIText : Codable {
    let raw: String?
    let rendered : String?
    let protected : Bool?
    
}
