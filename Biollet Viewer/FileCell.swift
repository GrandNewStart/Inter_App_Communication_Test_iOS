import UIKit

final class FileCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setData(_ file: BiolletFile) {
        if titleLabel != nil {
            titleLabel.text = file.name
            titleLabel.textColor = .label
            titleLabel.font = .systemFont(ofSize: 16.0)
        }
        if dateLabel != nil {
            dateLabel.text = file.modificationDate!.description
            dateLabel.textColor = .secondaryLabel
            dateLabel.font = .systemFont(ofSize: 14.0)
        }
    }
    
}
