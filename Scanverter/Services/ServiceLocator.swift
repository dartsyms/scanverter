import Foundation

typealias Services = [ObjectIdentifier: Any]

protocol ServiceLocator {
    func resolve<T>(type: T.Type) -> T?
    func register<T>(_ service: T)
}

final class Resolver: ServiceLocator {
    public static let shared = Resolver()
    
    private var services: Services = [:]
    
    func register<T>(_ service: T) {
        services[key(for: T.self)] = service
    }
    
    func resolve<T>(type: T.Type) -> T? {
        return services[key(for: T.self)] as? T
    }
    
    private func  key<T>(for type: T.Type) -> ObjectIdentifier {
        return ObjectIdentifier(T.self)
    }
}

@propertyWrapper
struct Injected<T> {
    private var service: T!
    public var container: ServiceLocator? = nil
    public var name: String?
    
    public init() {}
    
    public init(name: String? = nil, container: ServiceLocator? = nil) {
        self.name = name
        self.container = container
    }
    
    public var wrappedValue: T {
        mutating get {
            if self.service == nil {
                self.service = container?.resolve(type: T.self) ?? Resolver.shared.resolve(type: T.self)
            }
            return service
        }
        mutating set {
            service = newValue
        }
    }
    
    public var projectedValue: Injected<T> {
        get { return self }
        mutating set { self = newValue }
    }
}
