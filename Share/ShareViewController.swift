import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var importButton: UIButton!
    
    @IBAction func didTapImportButton(_ sender: Any) {
        guard let url = self.url else { return }
        self.importFile(url)
    }
    
    private var url: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getURL { url in
            guard let url = url else {
                print("(ERROR) ShareViewController.\(#function)-\(#line): no url found")
                DispatchQueue.main.async {
                    self.titleLabel.text = "(Unknown)"
                    self.textView.text = "(File Not Found)"
                    self.importButton.isEnabled = false
                }
                return
            }
            self.url = url
            self.readFileContents(url: url) { contents in
                guard let contents = contents else {
                    print("(ERROR) ShareViewController.\(#function)-\(#line): failed to read file contents in \(url.absoluteString)")
                    return
                }
                DispatchQueue.main.async {
                    self.titleLabel.text = String(url.lastPathComponent.dropLast(8))
                    self.textView.text = contents
                    self.importButton.isEnabled = true
                }
            }
        }
    }
    
    private func getURL(_ completionHandler: @escaping (_ url: URL?)->Void) {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem],
              let item = items.first else {
            print("(ERROR) ShareViewController.\(#function)-\(#line): no items")
            return
        }
        guard let providers = item.attachments else {
            print("(ERROR) ShareViewController.\(#function)-\(#line): no attachments")
            return
        }
        providers.forEach { provider in
            if provider.hasItemConformingToTypeIdentifier("com.supremaid.biollet") {
                provider.loadItem(forTypeIdentifier: "com.supremaid.biollet") { data , error in
                    if let error = error {
                        print("(ERROR) ShareViewController.\(#function)-\(#line): \(error)")
                        completionHandler(nil)
                        return
                    }
                    if let url = data as? URL {
                        print("(DEBUG) ShareViewController.\(#function)-\(#line): \(url.relativePath)")
                        completionHandler(url)
                        return
                    }
                }
            } else {
                print("(DEBUG) ShareViewController.\(#function)-\(#line): \(provider.debugDescription)")
            }
        }
        completionHandler(nil)
    }
    
    private func readFileContents(
        url: URL,
        _ completionHandler: @escaping (_ contents: String?)->Void
    ) {
        do {
            let data = try Data(contentsOf: url)
            let contents = String(data: data, encoding: .utf8)
            completionHandler(contents)
        } catch {
            print("(ERROR) ShareViewController.\(#function)-\(#line): \(error)")
            completionHandler(nil)
        }
    }
    
    private func importFile(_ url: URL) {
        do {
            guard let groupDirectory = FileManager
                .default
                .containerURL(forSecurityApplicationGroupIdentifier: .group)?
                .appendingPathComponent("Biollets")
            else {
                print("(ERROR) ShareViewController.\(#function)-\(#line): failed to get shared file directory")
                return
            }
            if !FileManager.default.fileExists(atPath: groupDirectory.relativePath) {
                try FileManager.default.createDirectory(at: groupDirectory, withIntermediateDirectories: true)
            }
            let destURL = groupDirectory
                .appendingPathComponent(url.lastPathComponent)
            try FileManager.default.copyItem(at: url, to: destURL)
            NotificationCenter.default.post(
                Notification(name: Notification.Name(rawValue: "biollet_file_added"))
            )
            self.extensionContext?.completeRequest(returningItems: nil)
        } catch {
            print("(ERROR) ShareViewController.\(#function)-\(#line): \(error)")
        }
    }
    
}
