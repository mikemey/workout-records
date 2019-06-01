import HealthKit
import UIKit

class WorkoutTableColors {
    static let defaultTextColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
    static let defaultBackgroundColor = UIColor(red: 205/255, green: 120/255, blue: 95/255, alpha: 1)
    static let deleteBackgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
}


class WorkoutTableCell: UITableViewCell {
    @IBOutlet var cellView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var distanceView: WorkoutUnitView!
    @IBOutlet var energyView: WorkoutUnitView!
    @IBOutlet var typeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        distanceView.create([0.67, 0.72, 1])
        energyView.create([0.55, 0.6, 1])
        distanceView.setUnitText(WRFormat.isMetric ? "km" : "mi", size: 11)
        energyView.setUnitText("kcal", size: 11)
        dateLabel.accessibilityIdentifier = "date"
        durationLabel.accessibilityIdentifier = "duration"
        distanceView.setAccessibilityIdentifier("distance")
        energyView.setAccessibilityIdentifier("energy")
    }
    
    private func setTextOn(_ lbl: UILabel, text: String, size: Int) {
        lbl.font = UIFont(name: "Verdana", size: CGFloat(size))
        lbl.textAlignment = .right
        lbl.textColor = WorkoutTableColors.defaultTextColor
        lbl.text = text
    }
    
    func setWorkout(_ workout: WorkoutData) {
        setTextOn(dateLabel, text: WRFormat.formatDate(workout.date), size: 16)
        setTextOn(durationLabel, text: WRFormat.formatDuration(workout.duration), size: 12)
        distanceView.setText(WRFormat.formatDistance(workout.distance ?? 0.0))
        energyView.setText(WRFormat.formatEnergy(workout.energy ?? 0))
        typeImage.image = UIImage(named: workout.activity.icon)
    
        cellView.backgroundColor = WorkoutTableColors.defaultBackgroundColor
    }
    
    func mark(forDeletion markForDeletion: Bool) {
        cellView.backgroundColor = markForDeletion
            ? WorkoutTableColors.deleteBackgroundColor
            : WorkoutTableColors.defaultBackgroundColor
    }
}

class WorkoutUnitView: UIView {
    private var textLabel: UILabel? = nil
    private var unitLabel: UILabel? = nil
    
    func create(_ widthRatios: [CGFloat]) {
        let height = self.frame.size.height
        let unitOffsetY: CGFloat = 5
        
        let widths = widthRatios.map({ v in v * self.frame.size.width })
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: widths[0], height: height))
        textLabel!.textColor = WorkoutTableColors.defaultTextColor
        textLabel!.font = .systemFont(ofSize: 18)
        textLabel!.textAlignment = .right
        
        let spacer = UIView(frame: CGRect(x: widths[0], y: 0, width: widths[1] - widths[0], height: height))

        unitLabel = UILabel(frame: CGRect(x: widths[1], y: unitOffsetY, width: widths[2] - widths[1], height: height - unitOffsetY))
        unitLabel!.textColor = WorkoutTableColors.defaultTextColor
        unitLabel!.font = .systemFont(ofSize: 11)

        self.addSubview(textLabel!)
        self.addSubview(spacer)
        self.addSubview(unitLabel!)
    }
    
    func setAccessibilityIdentifier(_ identifier: String) {
        textLabel!.accessibilityIdentifier = identifier
    }
    
    func setUnitText(_ text: String, size: Int) {
        unitLabel!.text = text
    }
    
    func setText(_ text: String) {
        textLabel!.text = text
    }
}
