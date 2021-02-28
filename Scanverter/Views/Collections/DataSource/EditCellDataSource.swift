import Combine

final class EditCellDataSource: ObservableObject {
    @Published private(set) var scannedDoc: ScannedDoc
    
    init(scannedDoc: ScannedDoc) {
        self.scannedDoc = scannedDoc
    }
}
