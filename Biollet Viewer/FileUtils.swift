import Foundation

struct FileUtils {
    
    static func getFilesFromGroupDirectory() {
        let fm = FileManager.default
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first,
              let groupDirectory = fm.containerURL(forSecurityApplicationGroupIdentifier: .group)?.appendingPathComponent("Biollets") else {
            print("(ERROR) FileUtils.\(#function)-\(#line): failed to get shared file directory")
            return
        }
        do {
            let items = try fm.contentsOfDirectory(atPath: groupDirectory.relativePath)
            for item in items {
                let name = String(item.dropLast(8))
                let source = groupDirectory.appendingPathComponent(name, conformingTo: .biollet)
                let dest = docUrl.appendingPathComponent(name, conformingTo: .biollet)
                try fm.moveItem(at: source, to: dest)
            }
        } catch {
            print("(ERROR) FileUtils.\(#function)-\(#line): \(error)")
        }
    }
    
    static func getFiles() -> [BiolletFile] {
        self.getFilesFromGroupDirectory()
        do {
            var files: [BiolletFile] = []
            let fm = FileManager.default
            guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
            let items = try fm.contentsOfDirectory(atPath: docUrl.relativePath)
            print("(DEBUG) Document Files: \(items)")
            for item in items {
                let name = String(item.dropLast(8))
                let url = docUrl.appendingPathComponent(name, conformingTo: .biollet)
                let data = try Data(contentsOf: url)
                guard let string = String(data: data, encoding: .utf8) else { continue }
                files.append(BiolletFile(name: name, contents: string))
            }
            return files
        } catch {
            print("(ERROR) FileUtils.\(#function)-\(#line): \(error)")
            return []
        }
    }
    
    
    
}
