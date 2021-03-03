import SwiftUI
import Combine
import AVFoundation

final class CameraViewModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    @Published var showAlertError = false
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    @Published var scannedDocs: [ScannedDoc] = .init()
    @Published var isPresentingImagePicker: Bool = false
    
    var alertError: AlertError!
    var session: AVCaptureSession
    
    public let publisher = PassthroughSubject<Bool, Never>()
    private var showOneLevelIn: Bool = false {
        willSet {
            publisher.send(showOneLevelIn)
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] photo in
            guard let pic = photo else { return }
            self?.photo = pic
            guard let img = pic.image?.cgImage else { return }
            self?.scannedDocs.append(ScannedDoc(image: img, date: Date()))
            self?.showOneLevelIn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self?.showOneLevelIn = true
            }
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] val in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] mode in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] val in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
    func didSelectImage(_ image: UIImage?) {
        isPresentingImagePicker = false
        guard image != nil, let picData = image!.pngData() else { return }
        self.photo = Photo(originalData: picData)
        scannedDocs.append(ScannedDoc(image: image!.cgImage!, date: Date()))
        showOneLevelIn = true
    }
}
