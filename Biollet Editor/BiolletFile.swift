import Foundation

struct BiolletFile {
    var url: String?
    let name: String
    let contents: String
    
    static func add(_ file: BiolletFile) {
        let fm = FileManager.default
        let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathExtension("\(file.name).biollet")
        do {
            try file.contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("(ERROR) BiolletFile.\(#function)-\(#line): \(error)")
        }
    }

    static func delete(_ name: String) {
        let fm = FileManager.default
        let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathExtension("\(name).biollet")
        do {
            try fm.removeItem(atPath: url.absoluteString)
        } catch {
            print("(ERROR) BiolletFile.\(#function)-\(#line): \(error)")
        }
    }
    
}

