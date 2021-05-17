//
//  UIViewController+Extension.swift
//  Continuum
//
//  Created by James Chun on 5/16/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentSimpleAlertWith(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}//End of extension
