import Foundation

enum Tab: Int {
    case folders
    case settings
    
    var index: Int {
        switch self {
        case .folders:
            return 1
        case .settings:
            return 2
        }
    }
    
    static func tabByIndex(_ index: Int) -> Tab {
        switch index {
        case 1:
            return folders
        case 2:
            return settings
        default:
            return folders
        }
    }
}
