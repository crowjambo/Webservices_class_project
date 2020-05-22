import Foundation

struct User: Codable {
    var id: Int?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }

     public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = (try values.decodeIfPresent(String.self, forKey: .name))
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
}

