//
//  ViewControllerHelper.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 4/8/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in } )
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true) {}
            })
            
        }
    }
    
}

