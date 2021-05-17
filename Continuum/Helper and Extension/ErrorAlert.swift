//
//  ErrorAlert.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class ErrorAlert {
    
    static func customAlertController(image: UIImage?, text: String?) -> UIAlertController {
        var alertMessage: String {
            if text == "" || image == nil {
                return "You cannot post... Please add more information"
            } else {
                return "Something went wrong..."
            }
        }
        
        let alertController = UIAlertController(title: "Alert!", message: alertMessage, preferredStyle: .actionSheet)
        
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAlertAction)
        
        return alertController
    }
    
}//End of class
