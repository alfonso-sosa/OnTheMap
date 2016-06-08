//
//  OTMStudentInformation.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 6/4/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

/**
 * Representation of Parse StudentLocation objects
 */
struct OTMStudentInformation {
    
    //Object id
    var objectId: String
    
    //unique key
    var uniqueKey: String
    
    //Student first name
    var firstName: String
    
    //Student last name
    var lastName: String
    
    //Location
    var mapString: String
    
    //Student submitted url
    var mediaUrl: String
    
    //Location latitude
    var latitude: Double
    
    //Location longitude
    var longitude: Double
    
    //Time when student location was created
    var createdAt: NSDate?
    
    //Time when student location was last updated
    var updatedAt: NSDate?
    
    /**
     * Initializer; takes the dictionary from a Parse request as a parameter.
     * Defaults missing values to empty strings or 0s.
     */
    init(fromDictionary dictionary: [String : AnyObject]){
        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        mapString = dictionary["mapString"] as? String ?? ""
        mediaUrl = dictionary["mediaURL"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
        createdAt = OTMDateFormatter.sharedInstance().formatter.dateFromString(dictionary["createdAt"] as! String)
        updatedAt = OTMDateFormatter.sharedInstance().formatter.dateFromString(dictionary["updatedAt"] as! String)
    }
    
}
