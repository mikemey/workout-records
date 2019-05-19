import UIKit

class ShowMoreTableCell: UITableViewCell {
    private static var defaultTextColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
    private var callbackHandler: (() -> Void)?
    
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setQueryDate(_ queryFromDate: Date, onShowMore: @escaping () -> Void) {
        setTextOn(dateLabel, text: WRFormat.formatDate(queryFromDate), size: 12)
        callbackHandler = onShowMore
    }
    
    @IBAction func onShowMoreClick(_ sender: Any) {
        if let cb = callbackHandler { cb() }
    }
    
    private func setTextOn(_ lbl: UILabel, text: String, size: Int) {
        lbl.font = UIFont(name: "Verdana", size: CGFloat(size))
        lbl.textColor = ShowMoreTableCell.defaultTextColor
        lbl.text = text
    }
}
