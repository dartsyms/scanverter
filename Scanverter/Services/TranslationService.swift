import Foundation
import Combine

enum ApiError: Error {
    case any(String)
}

private struct API {
    static let base = "https://translation.googleapis.com/language/translate/v2"
    
    struct translate {
        static let method = "POST"
        static let url = API.base
    }
    
    struct detect {
        static let method = "POST"
        static let url = API.base + "/detect"
    }
    
    struct languages {
        static let method = "GET"
        static let url = API.base + "/languages"
    }
}

public protocol TranslationService {
    func translate(q: String, target: String, source: String, format: String, model: String) -> AnyPublisher<Translations, Error>
    func detect(q: String) -> AnyPublisher<Detections, Error>
    func languages(target: String, model: String) -> AnyPublisher<Languages, Error>
    var apiKey: String { get set }
}

public class GoogleTranslation: TranslationService {
    private let session = URLSession(configuration: .default)
    
    public var apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /**
        Translates input text, returning translated text.
    
        - Parameters:
            - q: The input text to translate. Repeat this parameter to perform translation operations on multiple text inputs.
            - target: The language to use for translation of the input text.
            - format: The format of the source text, in either HTML (default) or plain-text. A value of html indicates HTML and a value of text indicates plain-text.
            - source: The language of the source text. If the source language is not specified, the API will attempt to detect the source language automatically and return it within the response.
            - model: The translation model. Can be either base to use the Phrase-Based Machine Translation (PBMT) model, or nmt to use the Neural Machine Translation (NMT) model. If omitted, then nmt is used. If the model is nmt, and the requested language translation pair is not supported for the NMT model, then the request is translated using the base model.
    */
    public func translate(q: String, target: String, source: String, format: String, model: String) -> AnyPublisher<Translations, Error> {
        guard var urlComponents = URLComponents(string: API.translate.url) else {
            return Future<Translations, Error> { promise in
                return promise(.failure(ApiError.any("Url components for url error")))
            }.eraseToAnyPublisher()
        }
        
        var queryItems: [URLQueryItem] = .init()
        queryItems.append(URLQueryItem(name: "key", value: self.apiKey))
        queryItems.append(URLQueryItem(name: "q", value: q))
        queryItems.append(URLQueryItem(name: "target", value: target))
        queryItems.append(URLQueryItem(name: "source", value: source))
        queryItems.append(URLQueryItem(name: "format", value: format))
        queryItems.append(URLQueryItem(name: "model", value: model))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Future<Translations, Error> { promise in
                return promise(.failure(ApiError.any("Url for with components error")))
            }.eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.translate.method
            
        return session.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .map { $0.data }
            .decode(type: Translations.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /**
        Detects the language of text within a request.
    
        - Parameters:
            - q: The input text upon which to perform language detection. Repeat this parameter to perform language detection on multiple text inputs.
    */
    public func detect(q: String) -> AnyPublisher<Detections, Error> {
        guard var urlComponents = URLComponents(string: API.detect.url) else {
            return Future<Detections, Error> { promise in
                return promise(.failure(ApiError.any("Url components for url error")))
            }.eraseToAnyPublisher()
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "q", value: q))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Future<Detections, Error> { promise in
                return promise(.failure(ApiError.any("Url for with components error")))
            }.eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.detect.method
        
        return session.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .map { $0.data }
            .decode(type: Detections.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /**
        Returns a list of supported languages for translation.
    
        - Parameters:
            - target: The target language code for the results. If specified, then the language names are returned in the name field of the response, localized in the target language. If you do not supply a target language, then the name field is omitted from the response and only the language codes are returned.
            - model: The translation model of the supported languages. Can be either base to return languages supported by the Phrase-Based Machine Translation (PBMT) model, or nmt to return languages supported by the Neural Machine Translation (NMT) model. If omitted, then all supported languages are returned. Languages supported by the NMT model can only be translated to or from English (en).
            - completion: A completion closure with an array of Language structures and an error if there is.
    */
    public func languages(target: String = "en", model: String = "base") -> AnyPublisher<Languages, Error> {
        guard var urlComponents = URLComponents(string: API.languages.url) else {
            return Future<Languages, Error> { promise in
                return promise(.failure(ApiError.any("Url components for url error")))
            }.eraseToAnyPublisher()
        }
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        queryItems.append(URLQueryItem(name: "target", value: target))
        queryItems.append(URLQueryItem(name: "model", value: model))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Future<Languages, Error> { promise in
                return promise(.failure(ApiError.any("Url for with components error")))
            }.eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = API.languages.method
        
        return session.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .map { $0.data }
            .decode(type: Languages.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
