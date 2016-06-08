//
//  OTMStudentData.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 6/5/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

/**
 * Singleton to store the retrieved student information 
 */
class OTMStudentData {
    
    //Results array
    var studentInformationList : [OTMStudentInformation]
    
    //Initializes the with JSON format
    init(){
        studentInformationList = []
    }
    
    
    //Singleton pattern
    class func sharedInstance() -> OTMStudentData {
        struct Singleton {
            static var sharedInstance = OTMStudentData()
        }
        return Singleton.sharedInstance
    }
}