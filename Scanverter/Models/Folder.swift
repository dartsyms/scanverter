import Foundation
import Combine
import PDFKit

struct Folder: Codable {
    var name: String
    var date: Date
    var isPasswordProtected: Bool
    var uid: UUID
    var files: [DocFile]
    var selected: Bool = false
    
    @discardableResult
    func save() -> AnyPublisher<Bool, Never> {
        DataManager.save(self, withName: uid.uuidString)
    }
    
    @discardableResult
    func delete(isDirectory: Bool = false) -> AnyPublisher<Bool, Never> {
        return DataManager.delete(file: uid.uuidString, isDirectory: isDirectory)
    }
    
    mutating func toggleSelection() {
        selected.toggle()
    }
}

extension Folder: Equatable, Hashable {
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
