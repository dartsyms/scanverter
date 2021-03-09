import Combine

final class SearchDataSource: ObservableObject {
    @Published var files: [DocFile] = .init()
    
    func loadAll() {
        let folders = DataManager.loadAll(Folder.self)
        folders
            .map { $0.files }
            .flatMap { $0 }
            .forEach { file in files.append(file)}
    }
}
