import UIKit

class CheckingTextField: UITextField, UITextFieldDelegate {
    private static let maxDistance: Double = 10000
    private static let maxFractionLen: Int = 3
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.isEmpty { return true }
        let currentText = textField.text ?? ""
        let newtext = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let newnum = Double(newtext)
        
        var tooManyFractions = false
        if let dotIndex = newtext.firstIndex(of: ".") {
            tooManyFractions = newtext.count - dotIndex.utf16Offset(in: newtext) > CheckingTextField.maxFractionLen
        }
        
        return newnum != nil
            && newnum! < CheckingTextField.maxDistance
            && !tooManyFractions
    }
}
