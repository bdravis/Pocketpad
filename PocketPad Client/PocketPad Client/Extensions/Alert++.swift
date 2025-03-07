//
//  Alert++.swift
//  PocketPad Client
//
//  Created by lemin on 3/7/25.
//

import UIKit

var currentUIAlertController: UIAlertController?

fileprivate let errorString = NSLocalizedString("Error", comment: "")
fileprivate let dismissString = NSLocalizedString("Okay", comment: "")

// create alerts without being attached to a view
extension UIApplication {
    func alert(title: String = errorString, body: String) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: dismissString, style: .cancel)
            cancelAction.accessibilityIdentifier = "AlertCancel"
            currentUIAlertController?.addAction(cancelAction)
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
