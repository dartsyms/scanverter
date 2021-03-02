import Foundation
import PDFKit
import Combine

protocol DocGenerator {
    func generatePDF() -> AnyPublisher<PDFDocument, Never>
    func getPDFdata() -> AnyPublisher<Data?, Never>
    var pages: [UIImage] { get set }
}

class PDFGenerator: NSObject, DocGenerator {
    var pages: [UIImage]
    private let pdfDocument = PDFDocument()
    private var pdfPage: PDFPage?
    
    var totalPages: Int { return pages.count }
    
    init(pages: [UIImage]) {
        self.pages = pages
    }
    
    func generatePDF() -> AnyPublisher<PDFDocument, Never> {
        return Future<PDFDocument, Never> { promise in
            DispatchQueue.global(qos: .background).async {
                for (index, image) in self.pages.enumerated() {
                    let A4paperSize = CGSize(width: 595, height: 842)
                    let bounds = CGRect.init(origin: .zero, size: A4paperSize)
                    let coreImage = image.cgImage!
                    let editedImage = UIImage(cgImage: coreImage, scale: 0.8, orientation: UIImage.Orientation.downMirrored)
                    self.pdfPage = PDFPage(image: editedImage)
                    self.pdfPage?.setBounds(bounds, for: .cropBox)
                    self.pdfDocument.insert(self.pdfPage!, at: index)
                }
                promise(.success(self.pdfDocument))
            }
        }.eraseToAnyPublisher()
    }
    
    func getPDFdata() -> AnyPublisher<Data?, Never> {
        return Future<Data?, Never> { promise in
            DispatchQueue.global(qos: .background).async { [weak self] in
                let data = self?.pdfDocument.dataRepresentation()
                promise(.success(data))
            }
        }.eraseToAnyPublisher()
    }
}
