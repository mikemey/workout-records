import UIKit

class UnitTextField: UITextField, UITextFieldDelegate {
    private static let maxValue: Double = 10000
    private static let maxFractionLen: Int = 2
    private static let enabledBGColor = UIColor(named: "workout_form_bg")
    private static let disabledBGColor = UIColor(named: "workout_form_disabled_bg")
    private static let widthRatios: [CGFloat] = [0.55, 0.6, 1]
    private var fractions = false
    private static let zeroDot = "0" + WRFormat.decimalSeparator
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func setProperties(unitText: String, placeholder: String, fractions: Bool) {
        setUnitText(unitText)
        setPlaceholder(placeholder)
        self.fractions = fractions
    }
    
    private func setUnitText(_ text: String) {
        let widths = UnitTextField.widthRatios.map { $0 * self.frame.size.width }
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        let unitView = UIView(frame: CGRect(x: 0, y: 0, width: widths[2] - widths[0], height: self.frame.size.height))
        unitView.isUserInteractionEnabled = true
        unitView.addGestureRecognizer(tap)
        
        let spacer = UILabel(frame: CGRect(x: 0, y: 0, width: widths[1] - widths[0], height: self.frame.size.height))
        unitView.addSubview(spacer)
        
        let unitOffsetY = CGFloat(2)
        let unitLabel = UILabel(frame: CGRect(x: widths[1] - widths[0], y: unitOffsetY, width: widths[2] - widths[1], height: self.frame.size.height - unitOffsetY))
        unitLabel.text = text
        unitLabel.font = .systemFont(ofSize: 14)
        unitView.addSubview(unitLabel)
        
        self.rightView = unitView
        self.rightViewMode = .always
    }
    
    private func setPlaceholder(_ placeholder: String) {
        let placeholderAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholderText,
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
        
        if self.fractions && currentText == "" && newtext == WRFormat.decimalSeparator {
            textField.text = UnitTextField.zeroDot
            return false
        }
        
        let newnum = self.getValue(newtext)
        return newnum != nil
            && newnum! < UnitTextField.maxValue
            && (self.fractions
            ? checkFractions(textField, newtext, currentText)
            : checkInteger(newnum!))
    }
    
    func getValue(_ text: String? = nil) -> Double? {
        let input = text ?? self.text ?? ""
        return Double(input.replacingOccurrences(of: ",", with: "."))
    }
    
    private func checkFractions(_ textField: UITextField, _ newtext: String, _ currentText: String) -> Bool {
        if let dotIndex = newtext.firstIndex(of: Character.init(WRFormat.decimalSeparator)) {
            let fractionLen = newtext.count - dotIndex.utf16Offset(in: newtext) - 1
            if fractionLen > UnitTextField.maxFractionLen {
                return false
            }
        }
        if currentText == "0" && newtext != UnitTextField.zeroDot {
            return false
        }
        return true
    }
    
    private func checkInteger(_ newnum: Double) -> Bool {
        return newnum > 0
    }
}
