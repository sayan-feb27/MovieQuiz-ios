import UIKit


final class AlertPresenter {
    func show (in controller: UIViewController, alert: AlertModel) {
        let uiAlert = UIAlertController(title: alert.title,
                                        message: alert.message,
                                        preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.action)
        uiAlert.addAction(action)
        
        controller.present(uiAlert, animated: true, completion: nil)
    }
}
