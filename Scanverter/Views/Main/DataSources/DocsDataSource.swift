import Combine
import PDFKit

typealias Files = [DocFile]

final class DocsDataSource: ObservableObject {
    @Published var files: Files = .init()
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    init(files: Files) {
        self.files = files
    }
    
    @discardableResult
    func remove(indexSet: IndexSet?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
           
        }.eraseToAnyPublisher()
    }
    
    func getUrl(forDoc doc: DocFile) -> URL? {
        return DataManager.getUrlForDoc(fromFolder: doc.parent.uid.uuidString, withFileName: doc.name)
    }
}
