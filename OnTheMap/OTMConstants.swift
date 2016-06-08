//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 2/22/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import Foundation

extension OTMClient {
    
    struct Constants {
        
        
        //Udacity API constants        
        static let BaseURL = "https://www.udacity.com/api/"
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let AccountKey = "key"
        static let AccountRegistered = "registered"
        static let UsersMethod = "users"
        static let UserKey = "user"
        static let CookieToken = "XSRF-TOKEN"
        static let CookieTokenHeader = "X-XSRF-TOKEN"
        
        //Parse API constants
        static let ParseURL = "https://api.parse.com/1/classes/"
        static let ParseMethodStudentLocation = "StudentLocation"
        static let ParseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseResults = "results"
        static let ParsePostObjId = "objectId"
        
        
        
        
    }
    
}