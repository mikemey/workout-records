import UIKit

class DatePickerController {
    private var callbackHandler: ((_ date: Date) -> Void)
    private var picker: UIDatePicker
    private var field: UITextField
//    private var instance: DatePickerController
    
    init(_ field: UITextField, _ toolbarBuilder: ToolbarBuilder, callback: @escaping (Date) -> Void) {
//        instance = self
        self.field = field
        callbackHandler = callback
        
        picker = UIDatePicker()
//        picker.addTarget(instance, action: #selector(DatePickerController.updateNewDate(_:)), for: .valueChanged)
        picker.addTarget(self, action: #selector(updateNewDate(_:)), for: .valueChanged)
        
        self.field.tintColor = UIColor.clear
        self.field.inputAccessoryView = createToolbar(toolbarBuilder)
        self.field.inputView = picker
        setDateNow()
    }
    
    private func createToolbar(_ toolbarBuilder: ToolbarBuilder) -> UIToolbar {
        toolbarBuilder.addActionButton("Now", target: self, action: #selector(setDateNow))
        toolbarBuilder.addButton(toolbarBuilder.spacer)
        toolbarBuilder.addButton(toolbarBuilder.doneButton)
        return toolbarBuilder.create()
    }
    
    @objc func setDateNow() {
        let now = Date()
        picker.maximumDate = now
        setNewDate(now)
    }
    
    @objc private func updateNewDate(_ sender: UIDatePicker) {
        setNewDate(sender.date)
    }
    
    private func setNewDate(_ date: Date) {
        field.text = WRFormat.formatDate(date)
        picker.date = date
        callbackHandler(date)
    }
}
