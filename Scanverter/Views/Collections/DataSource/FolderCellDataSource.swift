import Combine

final class FolderCellDataSource: ObservableObject {
    @Published private(set) var folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
}
