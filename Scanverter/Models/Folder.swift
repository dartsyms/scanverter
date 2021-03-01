import Foundation
import Combine

struct Folder: Codable {
    var name: String
    var date: Date
    var isPasswordProtected: Bool
    var uid: UUID
    
    func save() -> AnyPublisher<Bool, Never> {
        DataManager.save(self, withName: uid.uuidString)
    }
    
    func delete(isDirectory: Bool = false) -> AnyPublisher<Bool, Never> {
        return DataManager.delete(file: uid.uuidString, isDirectory: isDirectory)
    }
}
