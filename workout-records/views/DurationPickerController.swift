import UIKit

class DurationPickerController {
    static var pickerInstance: PickerTarget?
    
    static func wrap(_ field: UITextField, _ duration: TimeInterval, _ toolbar: UIToolbar,
                     callback: @escaping (TimeInterval) -> Void) {
        let picker = UIDatePicker()
        pickerInstance = PickerTarget(field, picker, callback)
        let target = pickerInstance!
        
        field.tintColor = UIColor.clear
        field.inputAccessoryView = toolbar
        field.inputView = picker
        
        picker.datePickerMode = .countDownTimer
        picker.addTarget(target, action: #selector(PickerTarget.updateNewDuration(_:)), for: .valueChanged)
        picker.countDownDuration = duration
        target.setNewDuration(duration)
    }
    
    class PickerTarget {
        let field: UITextField
        let picker: UIDatePicker
        let callbackHandler: ((_ duration: TimeInterval) -> Void)
        
        init(_ field: UITextField, _ picker: UIDatePicker, _ callback: @escaping (TimeInterval) -> Void) {
            self.field = field
            self.picker = picker
            self.callbackHandler = callback
        }
        
        @objc func updateNewDuration(_ sender: UIDatePicker) {
            setNewDuration(sender.countDownDuration)
        }
        
        func setNewDuration(_ duration: TimeInterval) {
            field.text = WRFormat.formatDuration(duration)
            callbackHandler(duration)
        }
    }
}
