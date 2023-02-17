import Foundation

struct BiolletFile {
    let name: String
    let contents: String
    
    static func add(_ file: BiolletFile) -> URL? {
        let fm = FileManager.default
        let url = fm.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(file.name, conformingTo: .biollet)
        do {
            try file.contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("(ERROR) BiolletFile.\(#function)-\(#line): \(error)")
            return nil
        }
    }
    
    static func delete(_ name: String) {
        let fm = FileManager.default
        let url = fm.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(name, conformingTo: .biollet)
        do {
            try fm.removeItem(at: url)
        } catch {
            print("(ERROR) BiolletFile.\(#function)-\(#line): \(error)")
        }
    }
    
    var modificationDate: Date? {
        do {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!.appendingPathComponent(name, conformingTo: .biollet)
            let attrs = try FileManager.default.attributesOfItem(atPath: url.relativePath)
            return attrs[FileAttributeKey.modificationDate] as? Date
        } catch {
            print("(ERROR) BiolletFile.\(#function)-\(#line): \(error)")
        }
        return nil
    }
    
}
