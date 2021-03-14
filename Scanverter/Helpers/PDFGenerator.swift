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
                    print("Scanned pages in generator: \(self.pages)")
//                    let A4paperSize = CGSize(width: 595, height: 842)
//                    let bounds = CGRect.init(origin: .zero, size: A4paperSize)
//                    let coreImage = image.cgImage!
//                    let editedImage = UIImage(cgImage: coreImage)
                    self.pdfPage = PDFPage(image: image)
//                    self.pdfPage?.setBounds(bounds, for: .cropBox)
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
