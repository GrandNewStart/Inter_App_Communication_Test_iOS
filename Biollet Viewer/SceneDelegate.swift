import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let context = URLContexts.first else { return }
        print("(DEBUG) URL received: \(context.url.absoluteString)")
        let urlComponents = URLComponents(
            url: context.url,
            resolvingAgainstBaseURL: false
        )
        if urlComponents?.scheme == "file" {
            self.handleFile(context.url)
            return
        }
    }
    
    private func handleFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            guard let contents = String(data: data, encoding: .utf8) else { return }
            let file = BiolletFile(name: url.lastPathComponent, contents: contents)
            guard let _ = BiolletFile.add(file) else {
                print("(ERROR) SceneDelegate.\(#function)-\(#line): failed to create file")
                return
            }
            NotificationCenter.default.post(
                Notification(name: Notification.Name(rawValue: "biollet_file_added"))
            )
            if let nvc = window?.rootViewController as? UINavigationController {
                if let vc = nvc.topViewController as? FileDetailViewController {
                    vc.setFile(file)
                    return
                }
                if let vc = nvc.topViewController as? FileListViewController {
                    vc.handleNewFile(file)
                    return
                }
            }
        } catch {
            print("(ERROR) SceneDelegate.\(#function)-\(#line): \(error)")
        }
    }

}

