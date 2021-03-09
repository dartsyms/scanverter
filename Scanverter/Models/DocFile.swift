import Foundation
import Combine

struct DocFile: Codable {
    var name: String
    var date: Date
    var uid: UUID
    var parent: Folder
}

extension DocFile: Equatable, Hashable {
    static func == (lhs: DocFile, rhs: DocFile) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
