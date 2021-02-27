import Foundation
import CoreGraphics
import CoreImage

class VNRectangleFeature: CIFeature {
    open var topLeft: CGPoint = .zero
    open var topRight: CGPoint = .zero
    open var bottomLeft: CGPoint = .zero
    open var bottomRight: CGPoint = .zero
    
    class func setValue(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> VNRectangleFeature {
        let object: VNRectangleFeature = VNRectangleFeature()
        object.topLeft = topLeft
        object.topRight = topRight
        object.bottomLeft = bottomLeft
        object.bottomRight = bottomRight
        return object
    }
}
