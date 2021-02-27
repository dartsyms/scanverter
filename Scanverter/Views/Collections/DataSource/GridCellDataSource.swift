import Combine

final class GridCellDataSource: ObservableObject {
    @Published private(set) var folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
}
