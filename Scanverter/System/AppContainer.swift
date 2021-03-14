import Foundation

class AppContainer {
    static func makeDefault() {
        Resolver.shared.register(PDFGenerator(pages: []) as DocGenerator)
        Resolver.shared.register(BiometricAuthentication() as TouchIdentification)
        Resolver.shared.register(GoogleTranslation(apiKey: Constants.googleTranslationApiKey) as TranslationService)
    }
}
