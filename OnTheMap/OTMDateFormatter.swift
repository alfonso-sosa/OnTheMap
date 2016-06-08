//
//  OTMDateFormatter.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 6/5/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

/**
 * Provides a singleton formatter
 */
class OTMDateFormatter {
    
    //Formatter instance
    let formatter = NSDateFormatter()
    
    //Initializes the with JSON format
    init(){
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    }
    
    
    //Singleton pattern
    class func sharedInstance() -> OTMDateFormatter {
        struct Singleton {
            static var sharedInstance = OTMDateFormatter()
        }
        return Singleton.sharedInstance
    }
}