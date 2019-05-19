import UIKit

class DurationPickerController {
    private var callbackHandler: ((_ date: TimeInterval) -> Void)
    private var field: UITextField
//    private var instance: DurationPickerController?
    private var picker: UIDatePicker
    
    init(_ textField: UITextField, _ duration: TimeInterval, _ toolbar: UIToolbar, callback: @escaping (TimeInterval) -> Void) {
//        instance = self
        callbackHandler = callback
        field = textField
        field.tintColor = UIColor.clear
        field.inputAccessoryView = toolbar
        
        picker = UIDatePicker()
        field.inputView = picker
        picker.countDownDuration = duration
        picker.datePickerMode = .countDownTimer
        picker.addTarget(self, action: #selector(updateNewDuration(_:)), for: .valueChanged)
        //        picker.addTarget(self, action: #selector(DurationPickerController.updateNewDuration(_:)), for: .valueChanged)
        setNewDuration(duration)
    }
    
    @objc private func updateNewDuration(_ sender: UIDatePicker) {
        setNewDuration(sender.countDownDuration)
    }
    
    private func setNewDuration(_ duration: TimeInterval) {
        field.text = WRFormat.formatDuration(duration)
        callbackHandler(duration)
    }
}
