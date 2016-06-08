//
//  OTMNetworkActivityIndicator.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 6/2/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

//Protocol for view that use the activity indicator
protocol OTMNetworkActivityIndicator {
    
    //Starts spinning
    func startActivity() -> Void
    
    //Stops spinning
    func stopActivity() -> Void
    
    //Returns the indicator
    func getIndicator() -> UIActivityIndicatorView
    
}

//Partial implementation to start / stop spinner
extension OTMNetworkActivityIndicator where Self: UIViewController {
    
    //Starts spinning
    func startActivity() -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.getIndicator().startAnimating()
        })
    }
    
    //Stops spinning
    func stopActivity() -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.getIndicator().stopAnimating()
        })
    }
    
}