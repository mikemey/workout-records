import GoogleMobileAds
import UIKit
import HealthKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var caloriesField: UITextField!
    @IBOutlet var workoutTableView: UITableView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var recordButton: UIButton!
    
    private var workoutData: [WorkoutData] = []
    private var queryFromDate = Date()
    private var selectedActivity: HKQuantityTypeIdentifier = WRFormat.typeIdentifiers[0]
    private var selectedDate = Date()
    private var selectedDuration: TimeInterval = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWithLocales()
        
        let toolbar = newToolbarBuilder().createDefault()
        distanceField.inputAccessoryView = toolbar
        distanceField.addTarget(self, action: #selector(checkRecordButtonState), for: .editingChanged)
        caloriesField.inputAccessoryView = toolbar
        caloriesField.addTarget(self, action: #selector(checkRecordButtonState), for: .editingChanged)
        
        createTypePicker(toolbar)
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
            distanceLabel.text = "Distance (mi)"
        }
    }
    
// =============== create fields methods =======================
// =============================================================

    func createAdbanner() {
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdUnitId")! as? String
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func newToolbarBuilder() -> ToolbarBuilder {
        return ToolbarBuilder(CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44), target: self, doneAction: #selector(endEditing))
    }
    
    func createTypePicker(_ toolbar: UIToolbar) {
        let typePicker = TypePickerView(typeField, toolbar: toolbar, callback: { typeId in
            self.selectedActivity = typeId
            if typeId == .activeEnergyBurned {
                self.distanceField.isEnabled = false
                self.distanceField.text = ""
                self.checkRecordButtonState()
            } else {
                self.distanceField.isEnabled = true
            }
        })
        typePicker.setNewActivity(0)
    }
    
    func createDatePicker() {
        DatePickerController.wrap(dateField, newToolbarBuilder(), callback: { date in
            self.selectedDate = date
        })
    }
    
    func createDurationPicker(_ toolbar: UIToolbar) {
        DurationPickerController.wrap(durationField, 3600, toolbar, callback: { interval in
            self.selectedDuration = interval
        })
    }

// ============== workout action methods =======================
// =============================================================

    func reloadWorkouts(_ querySetting: HKMQuerySetting?) {
        HealthKitManager.sharedInstance().readWorkouts(querySetting, finishBlock: { results, queryFromDate in
            self.workoutData = results
            self.queryFromDate = queryFromDate
            self.workoutTableView.reloadData()
        })
    }
    
    func deleteWorkout(_ workout: WorkoutData) {
        HealthKitManager.sharedInstance().deleteWorkout(workout, finishBlock: { error in
            if let error = error {
                AlertBuilder.showErrorAlert(on: self, title: "Error deleting workout", error: error)
            } else {
                self.reloadWorkouts(nil)
            }
        })
    }
    
// ==================== view methods ===========================
// =============================================================
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    @objc func checkRecordButtonState() {
        if (distanceField.text == "") && (caloriesField.text == "") {
            recordButton.isEnabled = false
            recordButton.alpha = 0.5
        } else {
            recordButton.isEnabled = true
            recordButton.alpha = 1
        }
    }
    
    @IBAction func onWriteWorkoutAction(_ sender: Any) {
        endEditing()
        let newWorkout = WorkoutData(selectedDate, selectedActivity)
        newWorkout.distance = distanceField.text.flatMap(Double.init) ?? 0
        newWorkout.calories = caloriesField.text.flatMap(Int.init) ?? 0
        newWorkout.duration = selectedDuration
        
        let storeHandler: (_ action: UIAlertAction?) -> Void = { action in
            HealthKitManager.sharedInstance().writeWorkout(newWorkout, finishBlock: { error in
                if let error = error {
                    AlertBuilder.showErrorAlert(on: self, title: "Error writing workout", error: error)
                } else {
                    self.reloadWorkouts(nil)
                }
            })
        }
        if newWorkout.distance > 0 || newWorkout.calories > 0 {
            if newWorkout.distance > 0 || selectedActivity == WRFormat.energyTypeId {
                storeHandler(nil)
            } else {
                let alertBuilder = AlertBuilder("", message: "No distance set.\nRecord as 'Calories only' ?")
                alertBuilder.addCancelAction(nil)
                alertBuilder.addDefaultAction("Record", handler: storeHandler)
                alertBuilder.show(self)
            }
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
            ? createShowMoreTableCell()
            : createWorkoutTableCell(workoutData[indexPath.row])
    }
    
    func createWorkoutTableCell(_ workout: WorkoutData) -> UITableViewCell {
        let cell = createTableCell("WorkoutTableCell") as! WorkoutTableCell
        cell.setWorkout(workout)
        return cell
    }
    
    func createShowMoreTableCell() -> UITableViewCell {
        let cell = self.createTableCell("ShowMoreTableCell") as! ShowMoreTableCell
        cell.setQueryDate(self.queryFromDate, onShowMore: { self.reloadWorkouts(.increasDate) })
        return cell
    }
    
    func createTableCell(_ cellId: String) -> UITableViewCell {
        var cell: UITableViewCell? = workoutTableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            let nib = Bundle.main.loadNibNamed(cellId, owner: self, options: nil)
            cell = nib?[0] as? UITableViewCell
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workoutCell = tableView.cellForRow(at: indexPath) as! WorkoutTableCell
            workoutCell.mark(forDeletion: true)
            let workout = workoutData[indexPath.row]
            
            let title = "Delete workout?"
            let message = "\(WRFormat.typeName(for: workout.type))"
                + "\nDate:  \(WRFormat.formatDate(workout.date))"
                + "\nDuration:  \(WRFormat.formatDuration(workout.duration))"
            let alertBuilder = AlertBuilder(title, message: message)
            alertBuilder.addCancelAction({ action in workoutCell.mark(forDeletion: false) })
            alertBuilder.addDefaultAction("Delete", handler: { action in self.deleteWorkout(workout) })
            alertBuilder.show(self)
        }
    }
}
