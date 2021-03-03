import UIKit
import Foundation

struct EditTool {
    let uid: String = UUID().uuidString
    let type: EditType
    let image: UIImage
    init(_ type: EditType, image: UIImage) {
        self.type = type
        self.image = image
    }
}

extension EditTool: Identifiable {
    var id: String {
        return uid
    }
}

extension EditTool: Equatable, Hashable {
    static func == (lhs: EditTool, rhs: EditTool) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

enum DocumentOrigin {
    case camera
    case photos
}

enum ProgressViewStyle {
    case status
    case progress
    case none
}

enum EditType {
    case add
    case crop
    case delete
    case save(SaveType)
    case ocr
    
    var tool: String {
        switch self {
        case .add:
            return "Add"
        case .crop:
            return "Crop"
        case .delete:
            return "Delete"
        case .save:
            return "Save"
        case .ocr:
            return "OCR"
        }
    }
}
