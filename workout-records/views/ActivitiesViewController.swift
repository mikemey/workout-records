import UIKit

class ActivitiesViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var activitiesTableView: UITableView!
    private typealias W = WRFormat
    
    private let sections = [
        W.singleActivitiesLabel, W.individualSportsLabel, W.teamSportsLabel, W.exerciseFitnessLabel, W.studioLabel,
        W.racketSportsLabel, W.outdoorLabel, W.snowIceSportsLabel, W.waterLabel, W.martialArtsLabel, W.otherLabel
    ]
    private let activities: [[Activity]] = [
        W.singleActivities, W.individualSportsActivities, W.teamSportsActivities, W.exerciseFitnessActivities, W.studioActivities,
        W.racketSportsActivities, W.outdoorActivities, W.snowIceSportsActivities, W.waterActivities, W.martialArtsActivities, W.otherActivities
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        let hrName = activities[indexPath.section][indexPath.row].hrName
        cell!.textLabel?.text = hrName
        return cell!
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
//        print("setting name: \(hrName)")

//        return cell
//        return hrName
    }
}
