import UIKit

class DatePickerController {
    static var pickerInstance: PickerTarget?
    
    static func wrap(_ field: UITextField, _ toolbarBuilder: ToolbarBuilder, callback: @escaping (Date) -> Void) {
        let picker = UIDatePicker()
        pickerInstance = PickerTarget(field, picker, callback)
        let target = pickerInstance!
        
        toolbarBuilder.addActionButton("Now", target: target, action: #selector(PickerTarget.setDateNow))
        toolbarBuilder.addButton(toolbarBuilder.spacer)
        toolbarBuilder.addButton(toolbarBuilder.doneButton)
        
        field.tintColor = UIColor.clear
        field.inputAccessoryView = toolbarBuilder.create()
        field.inputView = picker
        
        picker.datePickerMode = .dateAndTime
        picker.addTarget(target, action: #selector(PickerTarget.updateNewDate(_:)), for: .valueChanged)
        target.setDateNow()
    }
    
    class PickerTarget {
        let field: UITextField
        let picker: UIDatePicker
        let callbackHandler: ((_ date: Date) -> Void)
        
        init(_ field: UITextField, _ picker: UIDatePicker, _ callback: @escaping (Date) -> Void) {
            self.field = field
            self.picker = picker
            self.callbackHandler = callback
        }
        
        @objc func setDateNow() {
            let now = Date()
            picker.maximumDate = now
            setNewDate(now)
        }
        
        private func setNewDate(_ date: Date) {
            field.text = WRFormat.formatDate(date)
            picker.date = date
            callbackHandler(date)
        }
        
        @objc func updateNewDate(_ sender: UIDatePicker) {
            print(">> update date: ", sender.date)
            setNewDate(sender.date)
        }
    }
}
