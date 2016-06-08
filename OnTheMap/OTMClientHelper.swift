//
//  OTMClientHelper.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 2/23/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import Foundation

//Network client helper. Contains convenience methods to login, logout, post user details and update them
extension OTMClient {

    /**
     * Authenticates a user using the username and password parameters.
     * Success or error are reported using the completionHandler callback.
    */
    func authenticateWithCredentials(username: String,
                                     password: String,
                                     completionHandler: (success: Bool, errorString: String?) -> Void){
        //Arguments to invoke the service
        let jsonBody = ["udacity" : ["username" : username, "password": password]]
        
        //Posts credentials to Udacity's service, to create a new session.
        taskForPOST(Constants.BaseURL,
                    method:Constants.Session,
                    parameters: nil,
                    headerValues: ["Accept": "application/json", "Content-Type": "application/json"],
                    jsonBody: jsonBody,
                    resultIndex: 5){ (result, error) in
                        if let error = error {
                            completionHandler(success: false,
                                              errorString: error.code == 403 ? "Invalid username or password" : error.localizedDescription)
                        }
                        else {
                            //Store auth result
                            if let result = result as? [String:AnyObject]  {
                                //Session
                                let sessionInfo = result[Constants.Session] as! [String:AnyObject]
                                self.sessionID = sessionInfo[Constants.SessionID] as? String
                                //Account
                                let account = result[Constants.Account] as! [String:AnyObject]
                                self.accountKey = account[Constants.AccountKey] as? String
                                self.accountRegistered = account[Constants.AccountRegistered] as? Bool
                            }
                            else {
                                completionHandler(success: false, errorString: "Could not parse response")
                            }
                            completionHandler(success: true, errorString: nil)
                        }
        }
    }
    
    /**
     * Retrieves the details (firstname, lastname, other pulicly available data) of the user with the given id
     */
    func fetchUserPublicData(userId: String,
                           completionHandler: (success:Bool, errorString: String?)-> Void) {
        //Performs a GET request for the user
        taskForGET(Constants.BaseURL,
                   method: "\(Constants.UsersMethod)/\(userId)",
                   parameters: nil,
                   headerValues: nil,
                   resultIndex: 5){ (result, error) in
                    if let error = error {
                        print("error: \(error)")
                        completionHandler(success:false, errorString: error.localizedDescription)
                    }
                    else if let result = result as? [String:AnyObject]  {
                        let user = result[Constants.UserKey] as! [String: AnyObject]
                        self.userFirstName = user["first_name"] as? String
                        self.userLastName = user["last_name"] as? String
                    }
                    else {
                        completionHandler(success: false, errorString: "Could not parse response")
                    }
                    completionHandler(success: true, errorString: nil)
        }
        
    }
    
    /**
     * Gets a list of the most recently posted student locations, filtered by the parameters limit, skip and order.
     * The success flag and results are given back to the caller through the completionHandler function.
     */
    func getStudentLocations(limit: Int,
                             skip: Int,
                             order: String,
                             completionHandler: (success:Bool, results: [OTMStudentInformation]?, errorString: String?)-> Void) {
        //Performs a GET request for the recent posts
        taskForGET(Constants.ParseURL,
                   method: Constants.ParseMethodStudentLocation,
                   parameters: ["limit": "100", "order" : "-updatedAt"],
                   headerValues: ["X-Parse-Application-Id": Constants.ParseAppId, "X-Parse-REST-API-Key": Constants.ParseApiKey]){ (result, error) in
                    if let error = error {
                        completionHandler(success:false, results: nil, errorString: error.localizedDescription)
                    }
                    else if let result = result as? [String:AnyObject]  {
                        var studentData : [OTMStudentInformation] = []
                        let results = result[Constants.ParseResults] as! [[String: AnyObject]]
                        for dict in results {
                            let studentInfo = OTMStudentInformation(fromDictionary: dict)
                            studentData.append(studentInfo)
                        }
                        completionHandler(success: true, results: studentData, errorString: nil)
                    }
                    else {
                        completionHandler(success: false, results: nil, errorString: "Could not parse response")
                    }
        }
        
    }
    
    /**
     * Logs the user out of the Udacity session
     */
    func logout(completionHandler: (success:Bool, result: [String:AnyObject]?, errorString: String?)-> Void) {
        
        //Retrieves the cookie data from the device, to be used as a header value in the DELETE request
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Constants.CookieToken {
                xsrfCookie = cookie
            }
        }
        //Performs the DELETE request, to delete session data.
        taskForDELETE(Constants.BaseURL,
                      method: Constants.Session,
                      parameters: nil,
                      headerValues: [Constants.CookieTokenHeader : xsrfCookie!.value],
                      resultIndex: 5) {
                        (result, error) in
                        if let error = error {
                            completionHandler(success:false, result: nil, errorString: error.localizedDescription)
                        }
                        else if let result = result as? [String: AnyObject]{
                            completionHandler(success: true,
                                              result: result[Constants.Session] as? [String:AnyObject],
                                              errorString: nil)
                        }
                        else {
                            completionHandler(success: false, result: nil, errorString: "Could not parse response")
                        }
        }
    }
    
    /**
     * Posts a new user location to the Parse Service, with the details specified in the parameters.
     * Success or failure are reported to the caller in the completionHandler function.
     */
    func postUserLocation(firstname: String,
                          lastname: String,
                          mapString: String,
                          mediaURL: String,
                          latitude: Double,
                          longitude: Double,
                          completionHandler: (success: Bool, errorString: String?) -> Void){
        //Creates the json body of the request
        let jsonBody: [String: AnyObject] = ["uniqueKey" : OTMClient.sharedInstance().accountKey!,
                        "firstName" : firstname,
                        "lastName": lastname,
                        "mapString": mapString,
                        "mediaURL" : mediaURL,
                        "latitude" : latitude,
                        "longitude" : longitude]
        
        //Performs the post request
        taskForPOST(Constants.ParseURL,
                    method:Constants.ParseMethodStudentLocation,
                    parameters: nil,
                    headerValues: ["X-Parse-Application-Id": Constants.ParseAppId, "X-Parse-REST-API-Key": Constants.ParseApiKey, "Accept": "application/json", "Content-Type": "application/json"],
                    jsonBody: jsonBody){ (result, error) in
                        if let error = error {
                            completionHandler(success: false,
                                              errorString: error.localizedDescription)
                        }
                        else if (result as? [String:AnyObject]) != nil  {
                            completionHandler(success: true, errorString: nil)
                        }
                        else {
                            completionHandler(success: false, errorString: "Could not parse response")
                        }
        }
    }
    
    /**
     * GETs a the id of the previous post by this user, and returns it in the callback
     */
    func getUserPostId(uniqueKey: String,
                         completionHandler: (success: Bool, result: String?, errorString: String?) -> Void){
        //Performs the GET request
        taskForGET(Constants.ParseURL,
                   method:Constants.ParseMethodStudentLocation,
                   parameters: ["where": "{\"uniqueKey\":\"\(uniqueKey)\"}"],
                   headerValues: ["X-Parse-Application-Id": Constants.ParseAppId, "X-Parse-REST-API-Key": Constants.ParseApiKey, "Accept": "application/json"]){ (result, error) in
                    //Error during request
                    if let error = error {
                        completionHandler(success: false, result: nil, errorString: error.localizedDescription)
                    }
                    //Result is a dictionary
                    else if let result = result as? [String:AnyObject]  {
                        //'results' key has a list of locations, use the first found
                        if result[Constants.ParseResults]?.count > 0 {
                            completionHandler(
                                success: true,
                                result: (result[Constants.ParseResults]![0] as! [String: AnyObject])["objectId"] as? String,
                                errorString: nil)
                        }
                        // No previous posts by user, return nil
                        else {
                            completionHandler(success: true, result: nil,
                                              errorString: nil)
                        }
                    }
                    //Result not a dictionary
                    else {
                        completionHandler(success: false, result: nil,  errorString: "Could not parse response")
                    }
        }
    }
    
    /**
     * Posts a new user location to the Parse Service, with the details specified in the parameters.
     * Success or failure are reported to the caller in the completionHandler function.
     */
    func updateUserLocation(objectId: String,
                            firstname: String,
                            lastname: String,
                          mapString: String,
                          mediaURL: String,
                          latitude: Double,
                          longitude: Double,
                          completionHandler: (success: Bool, errorString: String?) -> Void){
        //Creates the json body of the request
        let jsonBody: [String: AnyObject] = ["uniqueKey" : OTMClient.sharedInstance().accountKey!,
                                             "firstName" : firstname,
                                             "lastName": lastname,
                                             "mapString": mapString,
                                             "mediaURL" : mediaURL,
                                             "latitude" : latitude,
                                             "longitude" : longitude]
        
        //Performs the post request
        taskForPUT(Constants.ParseURL,
                    method: "\(Constants.ParseMethodStudentLocation)/\(objectId)",
                    parameters: nil,
                    headerValues: ["X-Parse-Application-Id": Constants.ParseAppId, "X-Parse-REST-API-Key": Constants.ParseApiKey, "Accept": "application/json", "Content-Type": "application/json"],
                    jsonBody: jsonBody){ (result, error) in
                        if let error = error {
                            completionHandler(success: false,
                                              errorString: error.localizedDescription)
                        }
                        else if (result as? [String:AnyObject]) != nil  {
                            completionHandler(success: true, errorString: nil)
                        }
                        else {
                            completionHandler(success: false, errorString: "Could not parse response")
                        }
        }
    }
    
    
}
