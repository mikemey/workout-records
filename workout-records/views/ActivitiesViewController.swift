import UIKit

class ActivitiesViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    private typealias W = WRFormat
    private static let defaultTextColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
    private static let tableBackgroundColor = UIColor(red: 255/255, green: 248/255, blue: 248/255, alpha: 1)
    private static let borderColor = UIColor(red: 105/255, green: 62/255, blue: 50/255, alpha: 1).cgColor
    private static let selectionColor = UIColor(red: 128/255, green: 200/255, blue: 255/255, alpha: 1)
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var activitiesTableView: UITableView!
    
    var selectAction: ((Activity?) -> Void)? = nil
    private var selectedActivity: Activity? = nil
    private var previousIndexPath: IndexPath? = nil
    
    private let sections = [
        W.singleActivitiesLabel, W.individualSportsLabel, W.teamSportsLabel, W.exerciseFitnessLabel, W.studioLabel,
        W.racketSportsLabel, W.outdoorLabel, W.snowIceSportsLabel, W.waterLabel, W.martialArtsLabel, W.otherLabel
    ]
    private let activities: [[Activity]] = [
        W.singleActivities, W.individualSportsActivities, W.teamSportsActivities, W.exerciseFitnessActivities, W.studioActivities,
        W.racketSportsActivities, W.outdoorActivities, W.snowIceSportsActivities, W.waterActivities, W.martialArtsActivities, W.otherActivities
    ]
    
    private func findActivity(at index: IndexPath) -> Activity { return activities[index.section][index.row] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectButton.isEnabled = false
        view.layer.borderWidth = 1
        view.layer.borderColor = ActivitiesViewController.borderColor
        view.layer.shadowOpacity = 0.95
        view.layer.shadowColor = ActivitiesViewController.borderColor
        view.layer.shadowOffset = CGSize(width: 0,height: 5)
        view.layer.shadowRadius = 12
    }
    
    @IBAction func onBackToTopClick(_ sender: Any) {
        activitiesTableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func onSelectClick(_ sender: Any) {
        endView(with: selectedActivity)
    }
    
    @IBAction func onCloseClick(_ sender: Any) {
        endView(with: nil)
    }
    
    private func endView(with activity: Activity?) {
        if let selectAction = selectAction {
            selectAction(activity)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "activityCell")
        }
        let hrName = findActivity(at: indexPath).hrName
        setTextOn(cell!.textLabel!, text: hrName, size: 14)
        cell!.backgroundColor = ActivitiesViewController.tableBackgroundColor
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevPath = previousIndexPath, prevPath == indexPath {
            return onSelectClick(self)
        }
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = ActivitiesViewController.selectionColor
        previousIndexPath = indexPath
        selectButton.isEnabled = true
        selectedActivity = findActivity(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 28 : 14
    }
    
    private func setTextOn(_ lbl: UILabel, text: String, size: Int) {
        lbl.font = UIFont(name: "Verdana", size: CGFloat(size))
        lbl.textAlignment = .center
        lbl.textColor = ActivitiesViewController.defaultTextColor
        lbl.text = text
    }
}
