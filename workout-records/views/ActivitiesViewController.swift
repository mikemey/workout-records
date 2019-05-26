import UIKit

class ActivitiesViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    private typealias W = WRFormat
    
    @IBOutlet var selectButton: UIButton!
    
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
        
        view.layer.borderWidth = 0.5
        view.layer.shadowOpacity = 0.9
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0,height: 5)
        view.layer.shadowRadius = 10
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
        cell!.textLabel?.text = hrName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevPath = previousIndexPath, prevPath == indexPath {
            return onSelectClick(self)
        }
        previousIndexPath = indexPath
        selectButton.isEnabled = true
        selectedActivity = findActivity(at: indexPath)
    }
}
