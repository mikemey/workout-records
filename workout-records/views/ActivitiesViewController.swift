import UIKit

class ActivitiesViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    private typealias W = WRFormat
    private static let defaultTextColor = UIColor.label
    private static let tableBackgroundColor = UIColor(named: "activities_bg")
    private static let borderColor = UIColor(named: "activities_border")?.cgColor

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
    private let imageCache = ImageCache()
    
    private func findActivity(at index: IndexPath) -> Activity { return activities[index.section][index.row] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectButton.isEnabled = false
        selectButton.alpha = 0.35
        
        view.layer.borderWidth = 1
        view.layer.borderColor = ActivitiesViewController.borderColor
        view.layer.shadowOpacity = 0.95
        view.layer.shadowColor = ActivitiesViewController.borderColor
        view.layer.shadowOffset = CGSize(width: 0,height: 5)
        view.layer.shadowRadius = 12
        imageCache.preload(activities.flatMap { $0 })
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
    
    @IBAction func onInfoActivitiesClick(_ sender: Any) {
        if let url = URL(string: WRFormat.activitiesURL) {
            UIApplication.shared.open(url)
        }
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
        let activity = findActivity(at: indexPath)
        setTextOn(cell!.textLabel!, text: activity.hrName, size: 14)
        
        cell!.accessoryView = UIImageView(image: imageCache.getFor(activity))
        cell!.backgroundColor = ActivitiesViewController.tableBackgroundColor
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevPath = previousIndexPath, prevPath == indexPath {
            return onSelectClick(self)
        }
        previousIndexPath = indexPath
        selectButton.isEnabled = true
        selectButton.alpha = 1
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

class ImageCache {
    var cache = [String: UIImage]()
    
    func preload(_ activities: [Activity]) {
        for activity in activities {
            self.cache[activity.icon] = UIImage(named: WRFormat.activitiesIcon(activity))
        }
    }
    
    func getFor(_ activity: Activity) -> UIImage {
        return cache[activity.icon]!
    }
}
