import Foundation

public struct Detections: Codable {
    var items: [Detection]
    
    init(items: [Detection]) {
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case items = "detections"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = container.decodeSafelyIfPresent([Detection].self, forKey: .items) ?? []
    }
}

public struct Detection: Codable {
    let language: String?
    let isReliable: Bool?
    let confidence: Float?
    
    init(language: String?, isReliable: Bool?, confidence: Float?) {
        self.language = language
        self.isReliable = isReliable
        self.confidence = confidence
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case language, isReliable, confidence
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.language = container.decodeSafelyIfPresent(String.self, forKey: .language)
        self.isReliable = container.decodeSafelyIfPresent(Bool.self, forKey: .isReliable)
        self.confidence = container.decodeSafelyIfPresent(Float.self, forKey: .confidence)
    }
}
