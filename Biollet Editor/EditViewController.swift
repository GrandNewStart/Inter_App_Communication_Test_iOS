import UIKit
import UniformTypeIdentifiers

class EditViewController: UIViewController {

    private var file: BiolletFile? = nil
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func didTapButton(_ sender: Any) {
        self.textView.resignFirstResponder()
        self.writeSampleFile()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapBackground(_:))
            )
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleTextField.text = file?.name ?? "Biollet"
        self.textView.text = file?.contents ?? ""
    }
    
    func setFile(_ file: BiolletFile?) {
        self.file = file
    }
    
    func showFile(_ file: BiolletFile?) {
        self.file = file
        self.titleTextField.text = file?.name ?? "Biollet"
        self.textView.text = file?.contents ?? ""
    }
    
    @objc private func didTapBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    private func writeSampleFile() {
        let title = self.titleTextField.text ?? "Biollet"
        let contents = self.textView.text ?? ""

        let fileManager = FileManager.default
        
        if let existingURL = self.file?.url {
            let existingURL = URL(string: existingURL)!
            let newURL = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("\(title).biollet")
            do {
                try fileManager.moveItem(at: existingURL, to: newURL)
            } catch {
                print("(ERROR) failed to move file from \(existingURL) to \(newURL): \(error)")
                return
            }
        } else {
            let url = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("\(title).biollet")
            let data = contents.data(using: .utf8)!
            do {
                try data.write(to: url)
            } catch {
                print("(ERROR) failed to write to file \(error)")
                return
            }
        }
    }
    
//    private func useAppGroup() {
//        let title = self.titleTextField.text ?? "Title"
//        let contents = self.textView.text ?? ""
//
//        if var file = file {
//            file.title = title
//            file.contents = contents
//            File.update(file)
//            if let url = URL(string: "biolletviewer://edit?key=\(file.key)"),
//               UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url)
//                self.navigationController?.popViewController(animated: true)
//            }
//        } else {
//            let file = File.add(title: title, contents: contents)
//            if let url = URL(string: "biolletviewer://new?key=\(file.key)"),
//               UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url)
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
    
    private func useActionExtension(_ url: String) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success {
                guard let textItem = items?.first as? NSExtensionItem,
                      let itemProvider = textItem.attachments?.first else { return }
                if itemProvider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, error in
                        print("(DEBUG) \(item as? String ?? "")")
                    }
                }
            } else {
                print("(ERROR) \(error!)")
            }
        }
        self.present(activityVC, animated: true)
    }

}
