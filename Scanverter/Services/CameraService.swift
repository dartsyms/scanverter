import Foundation
import Combine
import AVFoundation
import Photos
import UIKit

protocol CameraController {
    var photo: Photo? { get set }
    var alertError: AlertError { get set }
    var session: AVCaptureSession { get }
    
    func checkForPermissions()
    func configure()
    func changeCamera()
    func focus(at focusPoint: CGPoint)
    func stop(completion: (() -> ())?)
    func start()
    func set(zoom: CGFloat)
    func capturePhoto()
}

public class CameraService: CameraController {
    typealias PhotoCaptureSessionID = String
    @Published public var flashMode: AVCaptureDevice.FlashMode = .off
    @Published public var shouldShowAlertView = false
    @Published public var shouldShowSpinner = false
    @Published public var willCapturePhoto = false
    @Published public var isCameraButtonDisabled = true
    @Published public var isCameraUnavailable = true
    @Published public var photo: Photo?
    
    public var alertError: AlertError = AlertError()
    public let session = AVCaptureSession()
    
    var isSessionRunning = false
    var isConfigured = false
    var setupResult: SessionSetupResult = .success

    private let sessionQueue = DispatchQueue(label: "session queue")
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,
                                                                                             .builtInDualCamera,
                                                                                             .builtInTrueDepthCamera],
                                                                               mediaType: .video,
                                                                               position: .unspecified)

    private let photoOutput = AVCapturePhotoOutput()
    
    private var inProgressPhotoCaptureDelegates: [Int64: PhotoCaptureHandler] = .init()
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    
    public func configure() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    public func checkForPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
            DispatchQueue.main.async {
                let primaryAction = {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                              options: [:],
                                              completionHandler: nil)
                }
                self.alertError = AlertError(title: "Camera Access",
                                             message: "Scanverter has no permission to use your camera, please update your privacy settings.",
                                             primaryButtonTitle: "To Settings",
                                             secondaryButtonTitle: nil,
                                             primaryAction: primaryAction,
                                             secondaryAction: nil)
                self.shouldShowAlertView = true
                self.isCameraUnavailable = true
                self.isCameraButtonDisabled = true
            }
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                print("Can't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Can't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            
        } else {
            print("Can't add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        self.isConfigured = true
        self.start()
    }
 
    public func changeCamera() {
        DispatchQueue.main.async {
            self.isCameraButtonDisabled = true
        }
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInWideAngleCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
                
            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                preferredPosition = .back
                preferredDeviceType = .builtInWideAngleCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    self.session.beginConfiguration()
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    if let connection = self.photoOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.photoOutput.maxPhotoQualityPrioritization = .quality
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.isCameraButtonDisabled = false
            }
        }
    }
    
    public func focus(at focusPoint: CGPoint) {
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }

    public func stop(completion: (() -> ())? = nil) {
        sessionQueue.async {
            if self.isSessionRunning {
                if self.setupResult == .success {
                    self.session.stopRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                    if !self.session.isRunning {
                        DispatchQueue.main.async {
                            self.isCameraButtonDisabled = true
                            self.isCameraUnavailable = true
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
    public func start() {
        sessionQueue.async {
            if !self.isSessionRunning && self.isConfigured {
                switch self.setupResult {
                case .success:
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                    if self.session.isRunning {
                        DispatchQueue.main.async {
                            self.isCameraButtonDisabled = false
                            self.isCameraUnavailable = false
                        }
                    }
                    
                case .configurationFailed, .notAuthorized:
                    print("Application not authorized to use camera")

                    DispatchQueue.main.async {
                        self.alertError = AlertError(title: "Camera Error",
                                                     message: "Camera configuration failed. Either your device camera is not available or it has no permission.",
                                                     primaryButtonTitle: "Accept",
                                                     secondaryButtonTitle: nil,
                                                     primaryAction: nil,
                                                     secondaryAction: nil)
                        self.shouldShowAlertView = true
                        self.isCameraButtonDisabled = true
                        self.isCameraUnavailable = true
                    }
                }
            }
        }
    }
    
    public func set(zoom: CGFloat) {
        let factor = zoom < 1 ? 1 : zoom
        let device = self.videoDeviceInput.device
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func capturePhoto() {
        if self.setupResult != .configurationFailed {
            self.isCameraButtonDisabled = true
            
            sessionQueue.async {
                if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                    photoOutputConnection.videoOrientation = .portrait
                }
                var photoSettings = AVCapturePhotoSettings()
                
                if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                }
                
                if self.videoDeviceInput.device.isFlashAvailable {
                    photoSettings.flashMode = self.flashMode
                }
                
                photoSettings.isHighResolutionPhotoEnabled = true
                
                if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                    photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                
                photoSettings.photoQualityPrioritization = .quality
                
                let photoCaptureProcessor = PhotoCaptureHandler(with: photoSettings, willCapturePhotoAnimation: { [weak self] in
                    DispatchQueue.main.async {
                        self?.willCapturePhoto = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self?.willCapturePhoto = false
                    }
                    
                }, completionHandler: { [weak self] photoCaptureProcessor in
                    if let data = photoCaptureProcessor.photoData {
                        self?.photo = Photo(originalData: data)
                        print("passing photo")
                    } else {
                        print("No photo data")
                    }
                    
                    self?.isCameraButtonDisabled = false
                    self?.sessionQueue.async {
                        self?.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                    }
                }, photoProcessingHandler: { [weak self] animate in
                    if animate {
                        self?.shouldShowSpinner = true
                    } else {
                        self?.shouldShowSpinner = false
                    }
                })
                self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
                self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            }
        }
    }
}
