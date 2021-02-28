import Combine
import UIKit
import Photos
import SwiftyTesseract

typealias Docs = [ScannedDoc]

enum ProgressViewType {
    case error, success, info
}

final class PhotoCollectionDataSource: ObservableObject {
    @Injected private var pdfGenerator: DocGenerator
    
    @Published var scannedDocs: [ScannedDoc] = .init()
    @Published var selectedImages: [UIImage] = .init()
    @Published var pageTitle: String = ""
    @Published var recognizedText: String = ""
    @Published var updateProgress: CGFloat = 0
    
    @Published var recognitionInProgress: Bool = false
    @Published var goToOCRResults: Bool = false
    @Published var showProgressView: Bool = false
    @Published var showProgressType: ProgressViewType = .info
    
    private var currentPage: Int = 1
    private var totalPages: Int = 0 {
        didSet {
            pageTitle = (1..<2).contains(totalPages) ? "Page 1" : "Page \(currentPage)/\(totalPages)"
        }
    }
    
    private var recognitionProgress: CGFloat = 0 {
        didSet {
            updateProgress += recognitionProgress
            print("Progress in recognition: \(recognitionProgress)")
        }
    }
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    var tools: [EditTool] = .init()
    
    var documentOrigin: DocumentOrigin?
    var pdfData: Data?
    var progressViewMessage: String = ""
    
    init(scannedDocs: Docs) {
        setup(withSources: scannedDocs)
    }
    
    private func setup(withSources docs: Docs) {
        docs.forEach { scannedDocs.append($0) }
        Constants.editTools.forEach { tools.append($0) }
        totalPages = scannedDocs.count
    }
    
    func cleanup() {
        pdfData?.removeAll()
        pdfData = nil
    }
    
    func cancelProcessing() {
        scannedDocs.removeAll()
    }
    
    func saveAsPDF() -> AnyPublisher<Bool, Never> {
        selectedImages.forEach { pdfGenerator.pages.append($0) }
        return pdfGenerator.generatePDF()
    }
    
    func saveAsImages() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [unowned self] promise in
            self.scannedDocs.forEach { doc in
                let image = UIImage(cgImage: doc.image)
                self.saveToPhotoLibrary(image)
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if !success {
                DispatchQueue.main.async {
                    self.progressViewMessage = "Error saving. Try again later."
                    self.showProgressType = .error
                    self.showProgressView = true
                }
            } else {
                self.progressViewMessage = "Saved."
                self.showProgressType = .success
                self.showProgressView = true
            }
        }
    }
    
    private func makeTextRecognition() {
        recognitionInProgress = true
        progressViewMessage = "Please wait... Recognition in progress..."
        showProgressType = .info
        self.showProgressView = true
        let tesseract = Tesseract(languages: [.english], engineMode: .default)
        let index = currentPage - 1
        tesseract.configure {}
        let image = UIImage(cgImage: scannedDocs[index].image)
        tesseract.performOCRPublisher(on: image)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Recognition completed")
                self.recognitionInProgress = false
                self.showProgressView = false
            } receiveValue: { result in
                self.recognizedText = result
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.goToOCRResults = true
                }
            }
            .store(in: &subscriptions)
    }
}
