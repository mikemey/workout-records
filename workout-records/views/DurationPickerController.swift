import UIKit

class DurationPickerController: UIView {
    typealias Statics = DurationPickerController
    static func wrap(_ field: UITextField, _ initialDuration: TimeInterval, _ toolbar: UIToolbar,
                     callback: @escaping (TimeInterval) -> Void) {
        let durationPicker = DurationPickerController(
            field, CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIDatePicker().frame.height),
            initialDuration, callback
        )
        
        field.inputAccessoryView = toolbar
        field.inputView = durationPicker
    }
    
    private static let hours = Array(0...23).map { v in "\(v)"}
    private static let minutes = Array(0...59).map { v in "\(v)"}
    
    private static func durationParts(of duration: TimeInterval) -> (Int, Int) {
        let totalMinutes = Int(duration / 60)
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    private let callback: ((TimeInterval) -> Void)
    private let textField: UITextField
    private var selectedHours = 0
    private var selectedMinutes = 0
    
    private init(_ field: UITextField, _ frame: CGRect, _ initialDuration: TimeInterval,
         _ callback: @escaping (TimeInterval) -> Void) {
        self.textField = field
        self.callback = callback
        super.init(frame: frame)
        
        (self.selectedHours, self.selectedMinutes) = Statics.durationParts(of: initialDuration)
        let halfWidth = frame.width / 2
        let hoursFrame = CGRect(x: 0, y: 0, width: halfWidth, height: frame.height)
        let minutesFrame = CGRect(x: halfWidth, y: 0, width: halfWidth, height: frame.height)
        let hoursPicker = UnitPickerView(
            frame: hoursFrame, data: Statics.hours, unit: "hour", units: "hours",
            initialSelectedRowIx: selectedHours, callback: { hoursRowIndex in
                self.selectedHours = hoursRowIndex
                self.updateDuration()
        })
        let minutesPicker = UnitPickerView(
            frame: minutesFrame, data: Statics.minutes, unit: "min", units: "min",
            initialSelectedRowIx: selectedMinutes, callback: { minutesRowIndex in
                self.selectedMinutes = minutesRowIndex
                self.updateDuration()
        })
        self.addSubview(hoursPicker)
        self.addSubview(minutesPicker)
        self.updateDuration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateDuration() {
        let duration = TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
        textField.text = WRFormat.formatDuration(duration)
        callback(duration)
    }
}

class UnitPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    private let callback: ((_ index: Int) -> Void)
    private let unitLabel: UILabel
    private let data: [String]
    private let unitText: String
    private let unitsText: String
    
    init(frame: CGRect, data: [String], unit: String, units: String,
         initialSelectedRowIx: Int, callback: @escaping (_ index: Int) -> Void) {
        self.data = data
        self.unitText = unit
        self.unitsText = units
        self.callback = callback
        self.unitLabel = UILabel(frame: CGRect(x: frame.width / 2 + 30, y: frame.midY - 15,
                                               width: 40, height: 30))
        unitLabel.font = .systemFont(ofSize: 14)
        unitLabel.textColor = .gray
        unitLabel.text = units
        
        super.init(frame: frame)
        self.addSubview(unitLabel)
        self.delegate = self
        self.dataSource = self
        self.selectRow(initialSelectedRowIx, inComponent: 0, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let valueLabel: UILabel = {
            if let reuseView = view as? UILabel { return reuseView }
            else {
                let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
                newLabel.font = .systemFont(ofSize: 22)
                newLabel.textAlignment = .right
                return newLabel
                
            }
        }()
        valueLabel.text = data[row]
        return valueLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.data[row] == "1" {
            unitLabel.text = self.unitText
        } else {
            unitLabel.text = self.unitsText
        }
        callback(row)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
}
