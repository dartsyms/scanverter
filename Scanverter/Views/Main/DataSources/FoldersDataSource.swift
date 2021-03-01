import Combine
import Foundation

final class FoldersDataSource: ObservableObject {
    @Published var folders: [Folder] = .init()
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    func loadFolders() {
        folders.removeAll()
        DataManager.loadAll(Folder.self).forEach { folders.append($0) }
        folders.sort { $0.date < $1.date }
    }
    
    @discardableResult
    func createNewFolder(withName name: String, secureLock: Bool = false) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            let folder = Folder(name: name, date: Date(), isPasswordProtected: secureLock, uid: UUID())
            folder.save()
                .receive(on: DispatchQueue.main)
                .sink { saved in
                    if saved {
                    self.loadFolders()
                }
                promise(.success(saved))
            }
            .store(in: &self.subscriptions)
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    func remove(indexSet: IndexSet?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let index = indexSet?.first else { promise(.success(false)); return }
            let folder = self.folders[index]
            folder.delete(isDirectory: true)
                .receive(on: DispatchQueue.main)
                .sink { deleted in
                    if deleted {
                        self.folders.remove(at: index)
                    }
                    promise(.success(deleted))
                }
                .store(in: &self.subscriptions)
        }.eraseToAnyPublisher()
    }
}
