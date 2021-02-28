import Foundation
import CoreGraphics

struct ScannedDoc {
    let uid: String = UUID().uuidString
    var image: CGImage
    var date: Date
}

extension ScannedDoc: Equatable, Hashable {
    static func == (lhs: ScannedDoc, rhs: ScannedDoc) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

extension ScannedDoc: Identifiable {
    var id: String {
        return uid
    }
}
