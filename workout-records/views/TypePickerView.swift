import UIKit
import HealthKit

class TypePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    private var callbackHandler: ((_ typeId: HKQuantityTypeIdentifier) -> Void)
    private var field: UITextField
    private var count: Int = WRFormat.typeIdentifiers.count
    
    init(_ field: UITextField, toolbar: UIToolbar, callback: @escaping (HKQuantityTypeIdentifier) -> Void) {
        self.field = field
        self.callbackHandler = callback

        super.init(frame: CGRect.zero)
        self.delegate = self
        self.dataSource = self
        self.showsSelectionIndicator = true
        self.field.inputView = self
        self.field.inputAccessoryView = toolbar
        self.field.tintColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNewActivity(_ index: Int) {
        field.text = WRFormat.typeNames[index]
        callbackHandler(WRFormat.typeIdentifiers[index])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return WRFormat.typeNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setNewActivity(row)
    }
}
