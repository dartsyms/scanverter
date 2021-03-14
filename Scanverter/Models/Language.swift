import Foundation

public struct Languages: Codable {
    var items: [Language]
    
    init(items: [Language]) {
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case items = "languages"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = container.decodeSafelyIfPresent([Language].self, forKey: .items) ?? []
    }
}


public struct Language: Codable {
    public let language: String?
    public let name: String?

    init(language: String?, name: String?) {
        self.language = language
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case language, name
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.language = container.decodeSafelyIfPresent(String.self, forKey: .language)
        self.name = container.decodeSafelyIfPresent(String.self, forKey: .name)
    }
}

