import HealthKit
import UIKit



class WorkoutTableCell: UITableViewCell {
    private static let defaultTextColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
    private static let defaultBackgroundColor = UIColor(red: 205/255, green: 120/255, blue: 95/255, alpha: 1)
    private static let deleteBackgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)

    @IBOutlet var cellView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var typeImage: UIImageView!
    @IBOutlet var distanceUnitLabel: UILabel!
    @IBOutlet var energyUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setTextOn(_ lbl: UILabel, text: String, size: Int) {
        lbl.font = UIFont(name: "Verdana", size: CGFloat(size))
        lbl.textAlignment = .right
        lbl.textColor = WorkoutTableCell.defaultTextColor
        lbl.text = text
    }
    
    func setWorkout(_ workout: WorkoutData) {
        setTextOn(dateLabel, text: WRFormat.formatDate(workout.date), size: 16)
        setTextOn(durationLabel, text: WRFormat.formatDuration(workout.duration), size: 12)
        setTextOn(distanceLabel, text: WRFormat.formatDistance(workout.distance), size: 18)
        setTextOn(caloriesLabel, text: WRFormat.formatCalories(workout.calories), size: 18)
        setTextOn(distanceUnitLabel, text: WRFormat.isMetric ? "km" : "mi", size: 11)
//        typeImage.image = UIImage(named: WRFormat.getImageFile(for: workout.type))
        cellView.backgroundColor = WorkoutTableCell.defaultBackgroundColor
    }
    
    func mark(forDeletion markForDeletion: Bool) {
        cellView.backgroundColor = markForDeletion
            ? WorkoutTableCell.deleteBackgroundColor
            : WorkoutTableCell.defaultBackgroundColor
    }
}
