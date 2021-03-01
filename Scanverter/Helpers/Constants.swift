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
    
    static var mockedDocs: [ScannedDoc] {
        var docs: [ScannedDoc] = .init()
        let names = ["imageWithText", "slideWithText"]
        for _ in 0..<2 {
            names.forEach {
                docs.append(ScannedDoc(image: UIImage(named: $0)!.cgImage!, date: Date()))
            }
        }
        return docs
    }
}
