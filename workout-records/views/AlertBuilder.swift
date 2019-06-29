import UIKit
import HealthKit

class AlertBuilder {
    private var alert: UIAlertController
    
    class func showErrorAlert(on delegate: UIViewController, title: String, error: Error) {
        var message = error.localizedDescription
        if (error as NSError?)?.code == HKError.Code.errorAuthorizationDenied.rawValue {
            message = "Please enable access in\nSettings -> Privacy -> Health"
        }
        let alertBuilder = AlertBuilder(title, message: message)
        alertBuilder.addOKAction()
        alertBuilder.show(delegate)
    }
    
    class func showOKAlert(on delegate: UIViewController, title: String, message: String) {
        let alertBuilder = AlertBuilder(title, message: message)
        alertBuilder.addOKAction()
        alertBuilder.show(delegate)
    }
    
    init(_ title: String, message: String) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    func show(_ target: UIViewController) {
        target.present(alert, animated: true)
    }
    
    func addDefaultAction(_ title: String, handler: @escaping (_ action: UIAlertAction) -> Void) {
        let action = UIAlertAction(title: title, style: .default, handler: handler)
        alert.addAction(action)
    }
    
    func addOKAction() {
        addDefaultAction("OK", handler: { _ in })
    }

    func addCancelAction(_ handler: ((UIAlertAction) -> Void)?) {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
        alert.addAction(cancel)
    }
}
