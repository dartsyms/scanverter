import Combine
import UIKit
import Photos
import SwiftyTesseract
import PDFKit

typealias Docs = [ScannedDoc]

enum ProgressViewType {
    case error, success, info
}

enum SaveType {
    case image, pdf
}

struct AlertData {
    var title: String = ""
    var message: String = ""
    var shouldBeShown: Bool = false
}

struct ProgressInfo {
    var progressViewMessage: String = ""
    var showProgressType: ProgressViewType = .info
    var showProgressView: Bool = false
}

struct RecognitionResult {
    var recognizedText: String = ""
    var goToOCRResults: Bool = false
}

struct PDFGenerationResult {
    var pdfDoc: PDFDocument? = nil
    var isPresentingFolderChooser = false
}

class ObservableArray<T>: ObservableObject {
    @Published var array: [T]
    
    init(array: [T] = .init()) {
        self.array = array
    }
  
    init(repeating value: T, count: Int) {
        array = Array(repeating: value, count: count)
    }
}

final class PhotoCollectionDataSource: ObservableObject {
    @Injected private var pdfGenerator: DocGenerator
    
    @Published var scannedDocs: [ScannedDoc] = .init()
    @Published var selectedDoc: ScannedDoc?
    @Published var selectedImages: [UIImage] = .init()
    @Published var pageTitle: String = ""
    @Published var recognizedText: String = ""
    @Published var updateProgress: CGFloat = 0
    
    @Published var recognitionInProgress: Bool = false
    
    @Published var selectedLibraryImage: UIImage?
    @Published var isPresentingImagePicker = false
    
    private(set) var sourceType: ImagePicker.SourceType = .photoLibrary
    
    func choosePhoto() {
        sourceType = .photoLibrary
        isPresentingImagePicker = true
    }

    func didSelectImage(_ image: UIImage?) {
        selectedLibraryImage = image
        if image != nil {
            scannedDocs.append(ScannedDoc(image: image!.cgImage!, date: Date()))
            print("Scandocs count \(scannedDocs.count)")
            selectedImages.append(image!)
            totalPages = scannedDocs.count
        }
        isPresentingImagePicker = false
    }
    
    public let alertPublisher: PassthroughSubject<AlertData, Never> = .init()
    private var alert: AlertData = AlertData() {
        willSet {
            alertPublisher.send(alert)
        }
    }
    
    public let dismissPublisher = PassthroughSubject<Bool, Never>()
    private var popToRoot: Bool = false {
        willSet {
            dismissPublisher.send(popToRoot)
        }
    }
    
    public let progressPublisher = PassthroughSubject<ProgressInfo, Never>()
    private var progress: ProgressInfo = ProgressInfo() {
        willSet {
            DispatchQueue.main.async {
                self.progressPublisher.send(self.progress)
            }
        }
    }
    
    public let ocrResultPublisher = PassthroughSubject<RecognitionResult, Never>()
    private var goToOCRResults: RecognitionResult = RecognitionResult() {
        willSet {
            DispatchQueue.main.async {
                self.ocrResultPublisher.send(self.goToOCRResults)
            }
        }
    }
    
    public let pdfGenerationPublisher = PassthroughSubject<PDFGenerationResult, Never>()
    private var pdfGenerationResult: PDFGenerationResult = PDFGenerationResult() {
        willSet {
            DispatchQueue.main.async {
                self.pdfGenerationPublisher.send(self.pdfGenerationResult)
            }
        }
    }
    
    @Published var currentPage: Int = 0
    private var totalPages: Int = 0 {
        didSet {
            pageTitle = (1..<2).contains(totalPages) ? "Page 1" : (totalPages == 0 ? "No Pages" : "Page \(currentPage + 1)/\(totalPages)")
        }
    }
    
    public let selectionPublisher = PassthroughSubject<Int, Never>()
    var selection: Int = 0 {
        didSet {
            selectionPublisher.send(1)
        }
    }
    
    private var recognitionProgress: CGFloat = 0 {
        didSet {
            updateProgress += recognitionProgress
            print("Progress in recognition: \(recognitionProgress)")
        }
    }
    
    private var subscriptions: Set<AnyCancellable> = .init()
    var recognitionRequest: AnyCancellable?
    
    var tools: [EditTool] = .init()
    
    var documentOrigin: DocumentOrigin?
    var pdfData: Data?
    
    init(scannedDocs: Docs) {
        setup(withSources: scannedDocs)
    }
    
    private func setup(withSources docs: Docs) {
        docs.forEach { scannedDocs.append($0) }
        Constants.editTools.forEach { tools.append($0) }
        totalPages = scannedDocs.count
        scannedDocs
            .compactMap({ UIImage(cgImage: $0.image) })
            .forEach { item in selectedImages.append(item) }
    }
    
    func cleanup() {
        pdfData?.removeAll()
        pdfData = nil
    }
    
    func cancelProcessing() {
        scannedDocs.removeAll()
    }
    
    func save(as type: SaveType) {
        switch type {
        case .image:
            saveAsImages()
                .receive(on: DispatchQueue.main)
                .sink { done in
                    if done {
                        self.popToRoot = true
                    }
                }
                .store(in: &subscriptions)
        case .pdf:
            saveAsPDF()
                .receive(on: DispatchQueue.main)
                .sink { pdfDoc in
                    print("pdf ready with pages count: \(pdfDoc.pageCount)")
                    self.pdfGenerationResult = PDFGenerationResult(pdfDoc: pdfDoc, isPresentingFolderChooser: true)
                }
                .store(in: &subscriptions)
        }
    }
    
    func save(pdfDoc: PDFDocument, namedAs named: String, in folder: Folder) -> AnyPublisher<Bool, Never> {
        DataManager.save(pdf: pdfDoc, withFileName: named, inFolder: folder.uid.uuidString)
    }
    
    func saveAsPDF() -> AnyPublisher<PDFDocument, Never> {
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
        self.progress = ProgressInfo(progressViewMessage: "Saving...",
                                     showProgressType: .info,
                                     showProgressView: true)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if !success {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.progress = ProgressInfo(progressViewMessage: "Error saving. Try again later.",
                                                 showProgressType: .error,
                                                 showProgressView: false)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.progress = ProgressInfo(progressViewMessage: "Saved.",
                                                 showProgressType: .success,
                                                 showProgressView: false)
                }
            }
        }
    }
    
    func pageSelectionDidChange(from oldValue: Int, to newValue: Int) {
        print("current page moved from \(oldValue) to \(newValue)")
        currentPage = newValue
    }
    
    func deletePage() {
        if scannedDocs.isEmpty {
            return
        }
        let index = currentPage < 0 ? 0 : currentPage
        scannedDocs.remove(at: index)
        totalPages = scannedDocs.count
        selectedImages.removeAll()
        scannedDocs.forEach { self.selectedImages.append(UIImage(cgImage: $0.image)) }
        if scannedDocs.isEmpty {
            popToRoot = true
        }
    }
    
    func addPage() {
        guard documentOrigin != nil else { return }
        switch documentOrigin! {
        case .camera:
            guard (0..<2).contains(scannedDocs.count) else {
                alert = AlertData(title: "Unable to add page",
                                  message: "Two pages have already been selected. Delete at least one and try again.",
                                  shouldBeShown: true)
                return
            }
            popToRoot = true
        case .photos:
            guard (0..<20).contains(scannedDocs.count) else {
                alert = AlertData(title: "Selection limit",
                                  message: "You have reached the maximum of 20 selected photos.",
                                  shouldBeShown: true)
                return
            }
            popToRoot = true
        }
        isPresentingImagePicker = false
    }
    
    func makeCrop() {
        print("To be implemented")
    }
    
    func makeTextRecognition() {
        print("make text recognition starts..")
        recognitionInProgress = true
        recognizedText.removeAll()
        progress = ProgressInfo(progressViewMessage: "Please wait... Recognition in progress...",
                                showProgressType: .info,
                                showProgressView: true)
        
        let tesseract = Tesseract(languages: [.english, .russian], engineMode: .default)
        print("Current page \(currentPage)")
        let index = currentPage
        tesseract.configure {}
        let image = UIImage(cgImage: scannedDocs[index].image)
        print("Prepare image with index \(index)")
        recognitionRequest = tesseract.performOCRPublisher(on: image)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Recognition completed")
            } receiveValue: { result in
                self.recognizedText = result
                self.recognitionInProgress = false
                self.progress = ProgressInfo(progressViewMessage: "",
                                        showProgressType: .info,
                                        showProgressView: false)
                print(result)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.goToOCRResults = RecognitionResult(recognizedText: self.recognizedText,
                                                            goToOCRResults: true)
                }
            }
    }
}
