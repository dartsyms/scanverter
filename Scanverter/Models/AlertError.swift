import Foundation

public struct AlertError {
    public var title: String = ""
    public var message: String = ""
    public var primaryButtonTitle = "Accept"
    public var secondaryButtonTitle: String?
    public var primaryAction: (() -> ())?
    public var secondaryAction: (() -> ())?
    
    public init(title: String = "",
                message: String = "",
                primaryButtonTitle: String = "Accept",
                secondaryButtonTitle: String? = nil,
                primaryAction: (() -> ())? = nil,
                secondaryAction: (() -> ())? = nil) {
        
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryAction = secondaryAction
    }
}

