import Foundation

struct Folder: Codable {
    var name: String
    var date: Date
    var isPasswordProtected: Bool
    var uid: UUID
    
    func save() {
        DataManager.save(self, withName: uid.uuidString)
    }
    
    func delete() {
        DataManager.delete(file: uid.uuidString)
    }
}
