import Combine
import UIKit
import Photos
import SwiftyTesseract

typealias Docs = [ScannedDoc]

enum ProgressViewType {
    case error, success, info
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

final class PhotoCollectionDataSource: ObservableObject {
    @Injected private var pdfGenerator: DocGenerator
    
    @Published var scannedDocs: [ScannedDoc] = .init()
    @Published var selectedImages: [UIImage] = .init()
    @Published var pageTitle: String = ""
    @Published var recognizedText: String = ""
    @Published var updateProgress: CGFloat = 0
    
    @Published var recognitionInProgress: Bool = false
    @Published var goToOCRResults: Bool = false
    
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
                    self.progress = ProgressInfo(progressViewMessage: "Error saving. Try again later.",
                                                 showProgressType: .error,
                                                 showProgressView: true)
                }
            } else {
                self.progress = ProgressInfo(progressViewMessage: "Saved.",
                                             showProgressType: .success,
                                             showProgressView: true)
            }
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
    }
    
    func makeCrop() {
        print("To be implemented")
    }
    
    func makeTextRecognition() {
        print("make text recognition starts..")
        recognitionInProgress = true
        progress = ProgressInfo(progressViewMessage: "Please wait... Recognition in progress...",
                                showProgressType: .info,
                                showProgressView: true)
        
        let tesseract = Tesseract(languages: [.english, .russian], engineMode: .default)
        let index = currentPage - 1
        tesseract.configure {}
        let image = UIImage(cgImage: scannedDocs[index].image)
        tesseract.performOCRPublisher(on: image)
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
                    self.goToOCRResults = true
                }
            }
            .store(in: &subscriptions)
    }
}
