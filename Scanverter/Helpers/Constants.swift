import Foundation
import CoreGraphics
import UIKit

public enum ModalOption {
    case mic, camera, search, none
}

public struct Constants {
    static let editTools = [
        EditTool.init(.add, image: UIImage(named: "addPageButton")!),
        EditTool.init(.crop, image: UIImage(named: "cropButton")!),
        EditTool.init(.delete, image: UIImage(named: "deletePageButton")!),
        EditTool.init(.ocr, image: UIImage(named: "ocrButton")!)
    ]
}
