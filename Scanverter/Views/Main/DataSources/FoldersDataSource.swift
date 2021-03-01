import Combine
import Foundation

final class FoldersDataSource: ObservableObject {
    @Published var folders: [Folder] = .init()
    
    func loadFolders() {
        DataManager.loadAll(Folder.self).forEach { folders.append($0) }
    }
    
    func createNewFolder(withName name: String, secureLock: Bool = false) {
        let folder = Folder(name: name, date: Date(), isPasswordProtected: secureLock, uid: UUID())
        folder.save()
        folders.insert(folder, at: 0)
    }
}
