import Foundation

public struct Translations: Codable {
    var items: [Translation]
    
    init(items: [Translation]) {
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case items = "translations"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = container.decodeSafelyIfPresent([Translation].self, forKey: .items) ?? []
    }
}


public struct Translation: Codable {
    var text: String?
    
    init(text: String?) {
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case text = "translatedText"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = container.decodeSafelyIfPresent(String.self, forKey: .text)
    }
}
