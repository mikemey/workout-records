import UIKit

class ShowMoreTableCell: UITableViewCell {
    private static var defaultTextColor = UIColor(named: "showMore_text")
    private var callbackHandler: (() -> Void)?
    
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setQueryDate(_ queryFromDate: Date, onShowMore: @escaping () -> Void) {
        setTextOn(dateLabel, text: WRFormat.formatDate(queryFromDate), size: 14)
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
