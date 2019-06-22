import UIKit

class DurationPickerController: UIView {
    static func wrap(_ field: UITextField, _ initialDuration: TimeInterval, _ toolbar: UIToolbar,
                     callback: @escaping (TimeInterval) -> Void) {
        let durationPicker = DurationPickerController(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIDatePicker().frame.height),
            initialDuration, callback
        )
        
        field.tintColor = UIColor.clear
        field.inputAccessoryView = toolbar
        field.inputView = durationPicker
        
        //        picker.addTarget(target, action: #selector(target.updateNewDuration(_:)), for: .valueChanged)
    }
    
    init(frame: CGRect, _ initialDuration: TimeInterval, _ callback: @escaping (TimeInterval) -> Void) {
        super.init(frame: frame)
        
        let halfWidth = frame.width / 2
        
        let hours = Array(0...23).map { v in "\(v)"}
        let minutes = Array(0...59).map { v in "\(v)"}
        let hoursFrame = CGRect(x: 0, y: 0, width: halfWidth, height: frame.height)
        let minutesFrame = CGRect(x: halfWidth, y: 0, width: halfWidth, height: frame.height)
        let hoursPicker = UnitPickerView(frame: hoursFrame, data: hours, unit: "hour", units: "hours")
        let minutesPicker = UnitPickerView(frame: minutesFrame, data: minutes, unit: "min", units: "min")
        
        self.addSubview(hoursPicker)
        self.addSubview(minutesPicker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UnitPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    private let callback: ((_ value: String) -> Void)
    private let unitLabel: UILabel
    private let data: [String]
    private let unitText: String
    private let unitsText: String
    
    
    init(frame: CGRect, data: [String], unit: String, units: String, callback: @escaping (String) -> Void) {
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
        self.callback(self.data[row])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
}
