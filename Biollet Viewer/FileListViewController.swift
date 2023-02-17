import UIKit

final class FileListViewController: UITableViewController {
    
    private var files: [BiolletFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "FileCell")
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        self.refreshControl?.addTarget(self, action: #selector(didRefresh(_:)), for: .valueChanged)
        self.navigationItem.title = "Files"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "new",
                style: .plain,
                target: self,
                action: #selector(didTapNewButton(_:))
            ),
            UIBarButtonItem(
                title: "import",
                style: .plain,
                target: self,
                action: #selector(didTapImportButton(_:))
            )
        ]
        self.files = FileUtils.getFiles()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didAddNewFile(_:)),
            name: Notification.Name(rawValue: "biollet_file_added"),
            object: nil
        )
    }
    
    func handleNewFile(_ file: BiolletFile) {
        self.files = FileUtils.getFiles()
        self.performSegue(withIdentifier: "toFile", sender: file)
    }
    
    @objc private func didRefresh(_ sender: Any) {
        self.refreshControl?.endRefreshing()
        self.files = FileUtils.getFiles()
        self.tableView.reloadData()
    }
    
    @objc private func didAddNewFile(_ sender: Notification) {
        self.files = FileUtils.getFiles()
        self.tableView.reloadData()
    }
    
    @objc private func didTapNewButton(_ sender: Any) {
        if let url = URL(string: "biolleteditor://new"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func didTapImportButton(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.biollet])
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFile",
           let vc = segue.destination as? FileDetailViewController,
           let file = sender as? BiolletFile {
            vc.file = file
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.files.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FileCell",
            for: indexPath
        ) as? FileCell
        cell?.setData(self.files[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        self.performSegue(
            withIdentifier: "toFile",
            sender: self.files[indexPath.row]
        )
    }
    
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool { return true }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let file = self.files[indexPath.row]
        return UISwipeActionsConfiguration(
            actions: [
                UIContextualAction(
                    style: .destructive,
                    title: "delete",
                    handler: { action, view, handler in
                        BiolletFile.delete(file.name)
                        self.files.removeAll(where: { $0.name == file.name })
                        self.tableView.reloadData()
                        handler(true)
                    }
                )
            ]
        )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
}

extension FileListViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.isEmpty { return }
        let url = urls.first!
        if url.startAccessingSecurityScopedResource() {
            do {
                var name = url.lastPathComponent
                name.removeLast(8)
                let data = try Data(contentsOf: url)
                guard let contents = String(data: data, encoding: .utf8) else { return }
                let file = BiolletFile(name: name, contents: contents)
                self.performSegue(
                    withIdentifier: "toFile",
                    sender: file
                )
                url.stopAccessingSecurityScopedResource()
            } catch {
                print("(ERROR) FileListViewController.\(#function)-\(#line): \(error)")
            }
        } else {
            print("(ERROR) FileListViewController.\(#function)-\(#line): unable to access url \(url.absoluteString)")
        }
    }
    
}
