import GoogleMobileAds
import UIKit
import HealthKit


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var activitiesView: UIView!
    
    @IBOutlet var activitiesButton: UIButton!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var energyField: UITextField!
    @IBOutlet var energyLabel: UILabel!
    @IBOutlet var workoutTableView: UITableView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var recordButton: UIButton!
    
    private var workoutData: [WorkoutData] = []
    private var queryFromDate = Date()
    private var selectedActivity: Activity = WRFormat.singleActivities[0]
    private var selectedDate = Date()
    private var selectedDuration: TimeInterval = 0.0
    private var tapGesture: UITapGestureRecognizer? = nil
    private let transitionDuration = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWithLocales()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture!)
        
        let toolbar = newToolbarBuilder().createDefault()
        distanceField.inputAccessoryView = toolbar
        distanceField.addTarget(self, action: #selector(checkRecordButtonState), for: .editingChanged)
        distanceField.setRightPadding(5)
        
        energyField.inputAccessoryView = toolbar
        energyField.addTarget(self, action: #selector(checkRecordButtonState), for: .editingChanged)
        energyField.setRightPadding(5)
        
        createInputBorders()
        createActivitiesPicker(toolbar)
        createDatePicker()
        createDurationPicker(toolbar)
        createAdbanner()
        reloadWorkouts(HKMQuerySetting.resetDate)
        checkRecordButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateWithLocales() {
        if !WRFormat.isMetric {
            distanceLabel.text = "mi"
        }
    }
    
// =============== create fields methods =======================
// =============================================================

    func createInputBorders() {
        let borderColor = UIColor.lightGray
        activitiesButton.layer.borderWidth = 1
        activitiesButton.layer.borderColor = borderColor.cgColor
        dateField.layer.addBorder([.left, .bottom, .right], borderColor, 1)
        distanceField.layer.addBorder([.bottom], borderColor, 1)
        distanceLabel.layer.addBorder([.bottom, .right], borderColor, 1)
        durationField.layer.addBorder([.left, .bottom, .right], borderColor, 1)
        energyField.layer.addBorder([.bottom], borderColor, 1)
        energyLabel.layer.addBorder([.bottom, .right], borderColor, 1)
    }
    
    func createAdbanner() {
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdUnitId")! as? String
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func newToolbarBuilder() -> ToolbarBuilder {
        return ToolbarBuilder(CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44), target: self, doneAction: #selector(endEditing))
    }
    
    func createActivitiesPicker(_ toolbar: UIToolbar) {
        activitiesView.isHidden = true
        activitiesView.alpha = 0
        
        activitiesButton.titleLabel?.font = .systemFont(ofSize: 16)
        activitiesButton.setTitle(selectedActivity.hrName, for: .normal)
        activitiesButton.setTitleColor(UIColor.black, for: .normal)
        let activitiesController = activitiesView.subviews[0].findViewController() as! ActivitiesViewController
        activitiesController.selectAction = { activity in
            self.closeActivitiesPicker()
            if let activity = activity {
                self.activitiesButton.setTitle(activity.hrName, for: .normal)
                self.selectedActivity = activity
                if activity == WRFormat.energyActivity {
                    self.distanceField.text = ""
                    self.distanceField.isEnabled = false
                } else {
                    self.distanceField.isEnabled = true
                }
                self.checkRecordButtonState()
            }
        }
        activitiesButton.addTarget(self, action: #selector(openActivitiesPicker), for: .touchDown)
    }
    
    func createDatePicker() {
        DatePickerController.wrap(dateField, newToolbarBuilder()) { date in
            self.selectedDate = date
        }
    }
    
    func createDurationPicker(_ toolbar: UIToolbar) {
        DurationPickerController.wrap(durationField, 3600, toolbar) { interval in
            self.selectedDuration = interval
        }
    }

// ============== workout action methods =======================
// =============================================================

    func reloadWorkouts(_ querySetting: HKMQuerySetting?) {
        HealthKitManager.sharedInstance().readWorkouts(querySetting) { results, queryFromDate in
            self.workoutData = results
            self.queryFromDate = queryFromDate
            self.workoutTableView.reloadData()
        }
    }
    
    func deleteWorkout(_ workout: WorkoutData) {
        HealthKitManager.sharedInstance().deleteWorkout(workout) { error in
            if let error = error {
                AlertBuilder.showErrorAlert(on: self, title: "Error deleting workout", error: error)
            } else {
                self.reloadWorkouts(nil)
            }
        }
    }
    
// ==================== view methods ===========================
// =============================================================
    
    @objc func endEditing(_ sender: Any?) {
        view.endEditing(true)
    }
    
    @objc func openActivitiesPicker(textField: UITextField) {
        endEditing(nil)
        view.removeGestureRecognizer(tapGesture!)
        activitiesView.isHidden = false
        UIView.animate(withDuration: transitionDuration, animations: {
            self.activitiesView.alpha = 1
        })
    }
    
    func closeActivitiesPicker() {
        view.addGestureRecognizer(tapGesture!)
        UIView.animate(withDuration: transitionDuration, animations: {
            self.activitiesView.alpha = 0
        }) { _ in self.activitiesView.isHidden = true }
    }
    
    @objc func checkRecordButtonState() {
        if WRFormat.isDistanceActivity(selectedActivity) {
           disableButtonIf((distanceField.text == "") && (energyField.text == ""))
        } else if WRFormat.energyActivity == selectedActivity {
            disableButtonIf((energyField.text == ""))
        } else {
            disableButtonIf(false)
        }
    }

    private func disableButtonIf(_ shouldDisable: Bool) {
        if shouldDisable {
            self.recordButton.isEnabled = false
            self.recordButton.alpha = 0.5
        } else {
            self.recordButton.isEnabled = true
            self.recordButton.alpha = 1
        }
    }
    
    @IBAction func onWriteWorkoutAction(_ sender: Any) {
        self.endEditing(nil)
        let newWorkout = WorkoutData(selectedDate, selectedDuration, selectedActivity)
        newWorkout.distance = distanceField.text.flatMap(Double.init)
        newWorkout.energy = energyField.text.flatMap(Int.init)
        
        let storeHandler: (_ action: UIAlertAction?) -> Void = { action in
            HealthKitManager.sharedInstance().writeWorkout(newWorkout) { error in
                if let error = error {
                    AlertBuilder.showErrorAlert(on: self, title: "Error writing workout", error: error)
                } else {
                    self.reloadWorkouts(nil)
                }
            }
        }

        if newWorkout.distance == nil && WRFormat.isDistanceActivity(selectedActivity) {
            let message = "No distance set.\nRecord as '\(WRFormat.energyActivity.hrName)' ?"
            let alertBuilder = AlertBuilder("", message: message)
            alertBuilder.addCancelAction(nil)
            alertBuilder.addDefaultAction("Record", handler: storeHandler)
            alertBuilder.show(self)
        } else {
            storeHandler(nil)
        }
    }
    
    // ================= table-view methods ========================
    // =============================================================

    func isLastRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == workoutData.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != workoutData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutData.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return isLastRow(indexPath)
            ? createShowMoreTableCell(indexPath.row)
            : createWorkoutTableCell(indexPath.row)
    }
    
    func createWorkoutTableCell(_ index: Int) -> UITableViewCell {
        let cell = createTableCell("WorkoutTableCell", index) as! WorkoutTableCell
        cell.setWorkout(workoutData[index])
        return cell
    }
    
    func createShowMoreTableCell(_ index: Int) -> UITableViewCell {
        let cell = self.createTableCell("ShowMoreTableCell", index) as! ShowMoreTableCell
        cell.setQueryDate(self.queryFromDate, onShowMore: { self.reloadWorkouts(.increasDate) })
        return cell
    }
    
    func createTableCell(_ cellId: String, _ index: Int) -> UITableViewCell {
        var cell: UITableViewCell? = workoutTableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            let nib = Bundle.main.loadNibNamed(cellId, owner: self, options: nil)
            cell = nib?[0] as? UITableViewCell
        }
        cell!.accessibilityIdentifier = "\(cellId)_\(index)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workoutCell = tableView.cellForRow(at: indexPath) as! WorkoutTableCell
            workoutCell.mark(forDeletion: true)
            let workout = workoutData[indexPath.row]
            
            let title = "Delete workout?"
            let message = "\(workout.activity.hrName)"
                + "\nDate:  \(WRFormat.formatDate(workout.date))"
                + "\nDuration:  \(WRFormat.formatDuration(workout.duration))"
            let alertBuilder = AlertBuilder(title, message: message)
            alertBuilder.addCancelAction({ action in workoutCell.mark(forDeletion: false) })
            alertBuilder.addDefaultAction("Delete", handler: { action in self.deleteWorkout(workout) })
            alertBuilder.show(self)
        }
    }
}
