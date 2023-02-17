import UIKit

class FileDetailViewController: UIViewController {
    
    var file: BiolletFile? = nil

    @IBOutlet weak var fileTitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "edit",
                style: .plain,
                target: self,
                action: #selector(didTapEditButton(_:))
            ),
            UIBarButtonItem(
                title: "save",
                style: .plain,
                target: self,
                action: #selector(didTapSaveButton(_:))
            )
        ]
    }
    
    @objc func didTapEditButton(_ sender: Any) {
//        if let file = file,
//           let url = URL(string: "biolleteditor://edit?key=\(file.key)"),
//           UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
    }
    
    @objc func didTapSaveButton(_ sender: Any) {
        guard let file = self.file else { return }
        if let _ = BiolletFile.add(file) {
            NotificationCenter.default.post(
                Notification(name: Notification.Name(rawValue: "biollet_file_added"))
            )
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let file = self.file {
            self.fileTitleLabel.text = file.name
            self.textView.text = file.contents
        }
    }
    
    func setFile(_ file: BiolletFile) {
        self.file = file
        if let file = self.file {
            self.fileTitleLabel.text = file.name
            self.textView.text = file.contents
        }
    }
    
}

