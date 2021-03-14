import Vision
import VisionKit
import PDFKit
import Combine

final class TextRecognizer {
    let cameraScan: VNDocumentCameraScan
    
    private var subscriptions: Set<AnyCancellable> = .init()
     
    init(cameraScan: VNDocumentCameraScan) {
        self.cameraScan = cameraScan
    }
     
    private let queue = DispatchQueue(label: "ru.otus.scanverter", qos: .default, attributes: [], autoreleaseFrequency: .workItem)
     
    func recognizeText(withCompletionHandler completionHandler: @escaping ([String]) -> Void) {
        queue.async {
            let images = (0..<self.cameraScan.pageCount).compactMap({ self.cameraScan.imageOfPage(at: $0).cgImage })
            let imagesAndRequests = images.map({ (image: $0, request: VNRecognizeTextRequest()) })
            let textPerPage = imagesAndRequests.map { image, request -> String in
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return "" }
                    return observations.compactMap({ $0.topCandidates(1).first?.string }).joined(separator: "\n")
                }
                catch {
                    print(error)
                    return ""
                }
            }
            self.generatePdf()
            DispatchQueue.main.async {
                completionHandler(textPerPage)
            }
        }
    }
    
    func generatePdf() {
        let pdfDocument = PDFDocument()
        for i in 0 ..< self.cameraScan.pageCount {
            if let image = self.cameraScan.imageOfPage(at: i).resize(toWidth: UIScreen.main.bounds.width - 40) {
                print("image size is \(image.size.width), \(image.size.height)")
                let pdfPage = PDFPage(image: image)
                pdfDocument.insert(pdfPage!, at: i)
            }
        }
        var folderToSave = Folder(name: "ScannedByVision", date: Date(), isPasswordProtected: false, uid: UUID(), files: [])
        folderToSave.save()
            .receive(on: DispatchQueue.main)
            .sink { done in
                if !done { return }
                let file = DocFile(name: "vk-\(Date().toFileNameString)", date: Date(), uid: UUID(), parent: folderToSave)
                DataManager.save(pdf: pdfDocument, withFileName: file.name, inFolder: folderToSave.uid.uuidString)
                    .receive(on: DispatchQueue.main)
                    .sink { saved in
                        folderToSave.files.append(file)
                        folderToSave.save()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
    }
}

