import Foundation
import Photos
import Combine
import CoreImage
import UIKit

class PhotoCaptureHandler: NSObject {
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    private let willCapturePhotoAnimation: () -> Void
    private let completionHandler: (PhotoCaptureHandler) -> Void
    private let photoProcessingHandler: (Bool) -> Void
    
    var photoData: Data?
    var scannedDocs: [ScannedDoc] = .init()
    
    lazy var context = CIContext()
    
    private var maxPhotoProcessingTime: CMTime?
    private var subscriptions: Set<AnyCancellable> = .init()
    
    var isBorderDetectionEnabled: Bool = true
    var imageDetectionConfidence: CGFloat = 0.0
    var multiPageEnabled: Bool = false
        
    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhotoAnimation: @escaping () -> Void,
         completionHandler: @escaping (PhotoCaptureHandler) -> Void,
         photoProcessingHandler: @escaping (Bool) -> Void) {
        
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        self.photoProcessingHandler = photoProcessingHandler
    }
    
    
}

extension PhotoCaptureHandler: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        maxPhotoProcessingTime = resolvedSettings.photoProcessingTimeRange.start + resolvedSettings.photoProcessingTimeRange.duration
    }

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async {
            self.willCapturePhotoAnimation()
        }
        
        guard let maxPhotoProcessingTime = maxPhotoProcessingTime else {
            return
        }
        
        let oneSecond = CMTime(seconds: 2, preferredTimescale: 1)
        if maxPhotoProcessingTime > oneSecond {
            DispatchQueue.main.async {
                self.photoProcessingHandler(true)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            self.photoProcessingHandler(false)
        }
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
            if let imgData = photoData {
                processImageFromCapture(imageData: imgData)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] images in
                        guard let `self` = self else { return }
                        images.forEach {
                            let doc = ScannedDoc(image: $0, date: Date())
                            self.scannedDocs.append(doc)
                        }
                    }
                    .store(in: &subscriptions)
            }
        }
    }
    
    func saveToPhotoLibrary(_ photoData: Data) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    DispatchQueue.main.async {
                        self.completionHandler(self)
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            DispatchQueue.main.async {
                self.completionHandler(self)
            }
            return
        } else {
            guard let data  = photoData else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
                return
            }
            self.saveToPhotoLibrary(data)
        }
    }
}

extension PhotoCaptureHandler {
    func filteredImageUsingEnhanceFilter(on image: CIImage) -> CIImage {
        return (CIFilter(name: "CIColorControls",
                         parameters: [kCIInputImageKey: image,
                                      "inputBrightness": NSNumber(value: 0.0),
                                      "inputContrast": NSNumber(value: 1.14),
                                      "inputSaturation": NSNumber(value: 0.0)])?.outputImage)!
    }
    
    func filteredImageUsingContrastFilter(on image: CIImage) -> CIImage {
        return CIFilter(name: "CIColorControls", parameters: ["inputContrast": 1.1,
                                                              kCIInputImageKey: image])!.outputImage!
    }
    
    func _biggestRectangle(inRectangles rectangles: [Any]) -> CIRectangleFeature? {
        if !(rectangles.count > 0) {
            return nil
        }
        var halfPerimiterValue: Float = 0
        var biggestRectangle: CIRectangleFeature = rectangles.first as! CIRectangleFeature
        for rect: CIRectangleFeature in rectangles as! [CIRectangleFeature] {
            let p1: CGPoint = rect.topLeft
            let p2: CGPoint = rect.topRight
            let width: CGFloat = CGFloat(hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y)))
            let p3: CGPoint = rect.topLeft
            let p4: CGPoint = rect.bottomLeft
            let height: CGFloat = CGFloat(hypotf(Float(p3.x) - Float(p4.x), Float(p3.y) - Float(p4.y)))
            let currentHalfPerimiterValue: CGFloat = height + width
            if halfPerimiterValue < Float(currentHalfPerimiterValue) {
                halfPerimiterValue = Float(currentHalfPerimiterValue)
                biggestRectangle = rect
            }
        }
        return biggestRectangle
    }
    
    func biggestRectangle(inRectangles rectangles: [Any]) -> VNRectangleFeature? {
        let rectangleFeature: CIRectangleFeature? = _biggestRectangle(inRectangles: rectangles)
        if rectangleFeature == nil { return nil }
        
        let points = [
            rectangleFeature?.topLeft,
            rectangleFeature?.topRight,
            rectangleFeature?.bottomLeft,
            rectangleFeature?.bottomRight
        ]
        
        var minimum = points[0]
        var maximum = points[0]
        for point in points {
            let minx = min((minimum?.x)!, (point?.x)!)
            let miny = min((minimum?.y)!, (point?.y)!)
            let maxx = max((maximum?.x)!, (point?.x)!)
            let maxy = max((maximum?.y)!, (point?.y)!)
            minimum?.x = minx
            minimum?.y = miny
            maximum?.x = maxx
            maximum?.y = maxy
        }
        let center = CGPoint(x: ((minimum?.x)! + (maximum?.x)!) / 2, y: ((minimum?.y)! + (maximum?.y)!) / 2)
        let angle = { (point: CGPoint) -> CGFloat in
            let theta = atan2(point.y - center.y, point.x - center.x)
            return fmod(.pi * 3.0 / 4.0 + theta, 2 * .pi)
        }
        let sortedPoints = points.sorted{angle($0!) < angle($1!)}
        let rectangleFeatureMutable = VNRectangleFeature()
        rectangleFeatureMutable.topLeft = sortedPoints[3]!
        rectangleFeatureMutable.topRight = sortedPoints[2]!
        rectangleFeatureMutable.bottomRight = sortedPoints[1]!
        rectangleFeatureMutable.bottomLeft = sortedPoints[0]!
        return rectangleFeatureMutable
    }
    
    func highAccuracyRectangleDetector() -> CIDetector? {
        var detector: CIDetector? = nil
        detector = CIDetector.init(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        return detector!
    }
    
    func drawHighlightOverlay(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: CGFloat(1), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(0.6)))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         parameters: ["inputExtent": CIVector(cgRect: image.extent),
                                                      "inputTopLeft": CIVector(cgPoint: topLeft),
                                                      "inputTopRight": CIVector(cgPoint:topRight),
                                                      "inputBottomLeft": CIVector(cgPoint:bottomLeft),
                                                      "inputBottomRight": CIVector(cgPoint:bottomRight)])
        return overlay.composited(over: image)
    }
    
    func rectangleDetectionConfidenceHighEnough(confidence:Float) -> Bool {
        return (confidence > 1.0)
    }
    
    func correctPerspective(for image: CIImage, withFeatures rectangleFeature: VNRectangleFeature) -> CIImage {
        var rectangleCoordinates = [String: Any]()
        rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: rectangleFeature.topLeft)
        rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: rectangleFeature.topRight)
        rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: rectangleFeature.bottomLeft)
        rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: rectangleFeature.bottomRight)
        return image.applyingFilter("CIPerspectiveCorrection", parameters: rectangleCoordinates)
    }
    
    func processImageFromCapture(imageData: Data) -> AnyPublisher<[CGImage], Never> {
        return Future<[CGImage], Never> { [weak self] promise in
            guard let `self` = self else { return promise(.success([])) }
            var photos: [CGImage] = .init()
            
            var enhancedImage = CIImage(data: imageData, options: [CIImageOption.colorSpace: NSNull()])
            guard enhancedImage != nil else { return promise(.success(photos)) }
            enhancedImage = self.filteredImageUsingContrastFilter(on: enhancedImage!)
            if self.isBorderDetectionEnabled && self.rectangleDetectionConfidenceHighEnough(confidence: Float(self.imageDetectionConfidence)) {
                if let rectangleFeature = self.biggestRectangle(inRectangles: (self.highAccuracyRectangleDetector()?.features(in: enhancedImage!))!) {
                    enhancedImage = self.correctPerspective(for: enhancedImage!, withFeatures: rectangleFeature)
                }
            }
            let transform = CIFilter(name: "CIAffineTransform")
            transform?.setValue(enhancedImage, forKey: kCIInputImageKey)
            let rotation = NSValue(cgAffineTransform: CGAffineTransform(rotationAngle: -90 * .pi / 180))
            transform?.setValue(rotation, forKey: "inputTransform")
            enhancedImage = transform?.outputImage
            guard enhancedImage != nil else { return promise(.success(photos)) }
            guard !enhancedImage!.extent.isEmpty else { return promise(.success(photos)) }
            //            context = CIContext(options: [CIContextOption.workingColorSpace: NSNull()])
            var bounds: CGSize = enhancedImage!.extent.size
            bounds = CGSize(width: 4 * bounds.width / 4, height: 4 * bounds.height / 4)
            let extent = CGRect(x: CGFloat((enhancedImage?.extent.origin.x)!), y: CGFloat((enhancedImage?.extent.origin.y)!), width: CGFloat(bounds.width), height: CGFloat(bounds.height))
            let bytesPerPixel: Int = 8
            let rowBytes: uint = uint(Float(bytesPerPixel) * Float(bounds.width))
            let totalBytes: uint = uint(Float(rowBytes) * Float(bounds.height))
            guard let byteBuffer = malloc(Int(totalBytes)) else { return promise(.success(photos)) }
            let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
            self.context.render(enhancedImage!,
                                toBitmap: byteBuffer,
                                rowBytes: Int(rowBytes),
                                bounds: extent,
                                format: CIFormat.RGBA8,
                                colorSpace: colorSpace)
            let bitmapContext = CGContext(data: byteBuffer, width: Int(bounds.width), height: Int(bounds.height), bitsPerComponent: bytesPerPixel, bytesPerRow: Int(rowBytes), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            let imgRef: CGImage? = bitmapContext?.makeImage()
            free(byteBuffer)
            if let imgRef = imgRef {
                photos.append(imgRef)
            }
            promise(.success(photos))
            self.imageDetectionConfidence = 0.0
        }.eraseToAnyPublisher()
    }
}
