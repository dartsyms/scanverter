import SwiftUI

public struct CustomProgressConfig: Hashable {
    var type = CustomProgressType.loading
    var title: String?
    var caption: String?

    var minSize: CGSize
    var cornerRadius: CGFloat

    var backgroundColor: Color

    var titleForegroundColor: Color
    var captionForegroundColor: Color

    var shadowColor: Color
    var shadowRadius: CGFloat

    var borderColor: Color
    var borderWidth: CGFloat

    var lineWidth: CGFloat

    // indefinite animated view and image share the size
    var imageViewSize: CGSize
    var imageViewForegroundColor: Color

    var successImage: String
    var warningImage: String
    var errorImage: String

    // Auto hide
    var shouldAutoHide: Bool
    var allowsTapToHide: Bool
    var autoHideInterval: TimeInterval

    // Haptics
    var hapticsEnabled: Bool

    public init(
        type: CustomProgressType         = .loading,
        title: String?                  = nil,
        caption: String?                = nil,
        minSize: CGSize                 = CGSize(width: 100.0, height: 100.0),
        cornerRadius: CGFloat           = 12.0,
        backgroundColor: Color          = .clear,
        titleForegroundColor: Color     = .primary,
        captionForegroundColor: Color   = .secondary,
        shadowColor: Color              = .clear,
        shadowRadius: CGFloat           = 0.0,
        borderColor: Color              = .clear,
        borderWidth: CGFloat            = 0.0,
        lineWidth: CGFloat              = 10.0,
        imageViewSize: CGSize           = CGSize(width: 100, height: 100),
        imageViewForegroundColor: Color = .primary,
        successImage: String            = "checkmark.circle",
        warningImage: String            = "exclamationmark.circle",
        errorImage: String              = "xmark.circle",
        shouldAutoHide: Bool            = false,
        allowsTapToHide: Bool           = false,
        autoHideInterval: TimeInterval  = 10.0,
        hapticsEnabled: Bool            = true
    ) {
        self.type = type

        self.title = title
        self.caption = caption

        self.minSize = minSize
        self.cornerRadius = cornerRadius

        self.backgroundColor = backgroundColor

        self.titleForegroundColor = titleForegroundColor
        self.captionForegroundColor = captionForegroundColor

        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius

        self.borderColor = borderColor
        self.borderWidth = borderWidth

        self.lineWidth = lineWidth

        self.imageViewSize = imageViewSize
        self.imageViewForegroundColor = imageViewForegroundColor

        self.successImage = successImage
        self.warningImage = warningImage
        self.errorImage = errorImage

        self.shouldAutoHide = shouldAutoHide
        self.allowsTapToHide = allowsTapToHide
        self.autoHideInterval = autoHideInterval

        self.hapticsEnabled = hapticsEnabled
    }
}
