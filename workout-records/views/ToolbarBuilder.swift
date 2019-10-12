import UIKit

class ToolbarBuilder {
    private var frame = CGRect.zero
    private var defaultButtons: [UIBarButtonItem] = []
    private var customButtons: [UIBarButtonItem] = []
    
    var doneButton: UIBarButtonItem
    var spacer: UIBarButtonItem
    
    init(_ frame: CGRect, target: Any?, doneAction: Selector) {
        self.frame = frame
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: doneAction)
        spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        defaultButtons = [spacer, doneButton]
    }
    
    func create() -> UIToolbar {
        return create(with: customButtons)
    }
    
    func createDefault() -> UIToolbar {
        return create(with: defaultButtons)
    }
    
    private func create(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolBar = UIToolbar(frame: frame)
        toolBar.tintColor = UIColor.secondaryLabel
        toolBar.items = items
        return toolBar
    }
    
    func addActionButton(_ title: String, target: Any?, action: Selector) {
        let button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        addButton(button)
    }
    
    func addButton(_ button: UIBarButtonItem) {
        customButtons.append(button)
    }
}
