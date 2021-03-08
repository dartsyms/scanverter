import Foundation
import Combine
import PDFKit

public class DataManager {
    static fileprivate func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    @discardableResult
    static func save<T: Encodable>(_ object: T, withName fileName: String, isDirectory: Bool = true) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            let url = docsUrl.appendingPathComponent(fileName, isDirectory: isDirectory)
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(object)
//                if FileManager.default.fileExists(atPath: url.path) {
//                    try FileManager.default.removeItem(at: url)
//                }
                if isDirectory && !FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                }
                let metadataFile = "\(fileName).json"
                try data.write(to: url.appendingPathComponent(metadataFile))
            } catch let error {
                print("Saving file error \(error.localizedDescription)")
                promise(.success(false))
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    static func load<T: Decodable>(_ fileName: String, with type: T.Type) -> T? {
        guard let docsUrl = getDocumentsDirectory() else { return nil }
        let metadataFile = "\(fileName).json"
        let url = docsUrl.appendingPathComponent(fileName, isDirectory: true).appendingPathComponent(metadataFile, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model
            } catch let error {
                print("Error decoding data: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    static func loadData(fromFile fileName: String, withExtension fileExtension: String = "") -> Data? {
        guard let docsUrl = getDocumentsDirectory() else { return nil }
        let url = docsUrl
                    .appendingPathComponent(fileName, isDirectory: false)
                    .appendingPathExtension(fileExtension)
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        return FileManager.default.contents(atPath: url.path)
    }
    
    static func loadAll<T: Decodable>(_ type: T.Type) -> [T] {
        guard let docsUrl = getDocumentsDirectory() else { return [] }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: docsUrl.path)
            var modelObjects: [T] = .init()
            files
                .compactMap({ load($0, with: type) })
                .forEach { file in modelObjects.append(file) }
            return modelObjects
        } catch let error {
            print("Error loading all: \(error.localizedDescription)")
            return []
        }
    }
    
    @discardableResult
    static func delete(file fileName: String, isDirectory: Bool = false) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            let url = docsUrl.appendingPathComponent(fileName, isDirectory: isDirectory)
            if isDirectory {
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for fileURL in fileURLs {
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            try FileManager.default.removeItem(at: fileURL)
                        }
                    }
                } catch {
                    promise(.success(false))
                }
            }
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    promise(.success(false))
                }
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    static func save(pdf: PDFDocument, withFileName fileName: String, inFolder folderName: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            var folder = load(folderName, with: Folder.self)
            if folder == nil { return promise(.success(false)) }
            let pdfName = "\(fileName).pdf"
            
            let pdfDoc = DocFile(name: pdfName, date: Date(), uid: UUID(), parent: folder!)
            folder!.files.append(pdfDoc)
            folder!.save()
            let folderUrl = docsUrl.appendingPathComponent(folder!.uid.uuidString, isDirectory: true)
            do {
                if let data = pdf.dataRepresentation() {
                    try data.write(to: folderUrl.appendingPathComponent(pdfName))
                } else {
                    promise(.success(false))
                }
            } catch {
                promise(.success(false))
            }
//            let pathToSave =
//            let saved = pdf.write(to: pathToSave)
            print("Path to save: \(folderUrl)")
            print("pdf successfully saved")
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    static func delete(pdfDoc: DocFile) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            guard let docsUrl = getDocumentsDirectory() else { return promise(.success(false)) }
            let url = docsUrl
                .appendingPathComponent(pdfDoc.parent.uid.uuidString, isDirectory: true)
                .appendingPathComponent(pdfDoc.name, isDirectory: false)
//                .appendingPathExtension("pdf")
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    promise(.success(false))
                }
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    static func getUrlForDoc(fromFolder folder: String, withFileName fileName: String, withExtension fileExtension: String = "") -> URL? {
        guard let docsUrl = getDocumentsDirectory() else { return nil }
        let url = docsUrl
                    .appendingPathComponent(folder, isDirectory: true)
                    .appendingPathComponent(fileName, isDirectory: false)
        print(url)
        return url
    }
}
