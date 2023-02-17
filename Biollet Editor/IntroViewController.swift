import UIKit

final class IntroViewController: UIViewController {
    
    @IBAction func didTapAtWriteButton(_ sender: Any) {
        performSegue(withIdentifier: "toEdit", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit",
           let vc = segue.destination as? EditViewController,
           let file = sender as? BiolletFile {
            vc.setFile(file)
        }
    }
    
}
