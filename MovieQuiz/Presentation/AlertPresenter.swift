import UIKit


class AlertPresenter {
    weak var mainController: UIViewController?
    
    func show (alert: AlertModel) {
        let uiAlert = UIAlertController(title: alert.title,
                                      message: alert.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.action)
        uiAlert.addAction(action)
        
        mainController?.present(uiAlert, animated: true, completion: nil)
    }
}
