import UIKit

class UnitTextField: UITextField, UITextFieldDelegate {
    private static let maxDistance: Double = 10000
    private static let maxFractionLen: Int = 3
    private static let enabledBGColor = UIColor(white: 0.97, alpha: 1)
    private static let disabledBGColor = UIColor(white: 0.80, alpha: 1)

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func setProperties(unitText: String, placeholder: String) {
        setUnitText(unitText)
        setPlaceholder(placeholder)
    }
    
    private func setUnitText(_ text: String) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        let unitView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: self.frame.size.height))
        unitView.isUserInteractionEnabled = true
        unitView.addGestureRecognizer(tap)

        let spacer = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        unitView.addSubview(spacer)
        
        let unitOffsetY = CGFloat(2)
        let unitLabel = UILabel(frame: CGRect(x: 10, y: unitOffsetY, width: 40, height: self.frame.size.height - unitOffsetY))
        unitLabel.text = text
        unitLabel.font = .systemFont(ofSize: 14)
        unitView.addSubview(unitLabel)
        
        self.rightView = unitView
        self.rightViewMode = .always
    }

    private func setPlaceholder(_ placeholder: String) {
        let placeholderAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.baselineOffset: NSNumber(-1)
        ]
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
    }
    
    func enable(when enable: Bool) {
        self.isEnabled = enable
        if enable {
            self.backgroundColor = UnitTextField.enabledBGColor
        } else {
            self.text = ""
            self.backgroundColor = UnitTextField.disabledBGColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let currentText = textField.text ?? ""
        let newtext = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let newnum = Double(newtext)
        var tooManyFractions = false
        if let dotIndex = newtext.firstIndex(of: ".") {
            tooManyFractions = newtext.count - dotIndex.utf16Offset(in: newtext) > UnitTextField.maxFractionLen
        }
        
        return newnum != nil
            && newnum! < UnitTextField.maxDistance
            && !tooManyFractions
    }
}
