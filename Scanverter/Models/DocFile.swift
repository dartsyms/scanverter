import Foundation
import Combine

struct DocFile: Codable {
    var name: String
    var date: Date
    var uid: UUID
    var parent: Folder
}
