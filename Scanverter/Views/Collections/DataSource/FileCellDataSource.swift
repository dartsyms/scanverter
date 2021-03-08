import Combine

final class FileCellDataSource: ObservableObject {
    @Published private(set) var file: DocFile
    
    init(file: DocFile) {
        self.file = file
    }
}
