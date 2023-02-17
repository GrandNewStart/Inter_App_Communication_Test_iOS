import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let context = URLContexts.first else { return }
        print("(DEBUG) URL received: \(context.url.absoluteString)")
        if context.url.lastPathComponent.hasSuffix(".biollet") {
            self.openFile(context.url)
            return
        }
    }
    
    func openFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            guard let contents = String(data: data, encoding: .utf8) else { return }
            var fileName = url.lastPathComponent
            fileName.removeLast(8)
            let file = BiolletFile(
                url: url.absoluteString,
                name: fileName,
                contents: contents
            )
            guard let nvc = window?.rootViewController as? UINavigationController else {
                print("(ERROR) failed to get root view controller")
                return
            }
            if let vc = nvc.topViewController as? EditViewController {
                vc.showFile(file)
                return
            }
            if let vc = nvc.topViewController as? IntroViewController {
                vc.performSegue(withIdentifier: "toEdit", sender: file)
                return
            }
        } catch {
            print("(ERROR) SceneDelegate.\(#function): \(error)")
        }
    }
    
}

