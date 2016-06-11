//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 2/11/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import Foundation

//Network Client object
class OTMClient : NSObject {
    
    //url session to create requests
    var session: NSURLSession
    //Session id (login)
    var sessionID: String? = nil
    //The account key, used to query and update info of the user that has logged in
    var accountKey: String? = nil
    //Indicates if the account is registered
    var accountRegistered: Bool? = nil
    
    //User and lastname of the user that has logged in using this device.
    var userFirstName: String? = nil
    var userLastName: String? = nil
    
    //Inits the url session
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]?) -> String {
        if let parameters = parameters {
            
            var urlVars = [String]()
            
            for (key, value) in parameters {
                
                /* Make sure that it is a string value */
                let stringValue = "\(value)"
                
                /* Escape it */
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
                
            }
            
            return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
        }
        else {
            return ""
        }
        
    }
    
    //Parses the specified data as JSON and returns the result in the completion handler.
    class func parseJSONWithCompletionHandler(data: NSData,
                                              skip: Int,
                                              completionHandler: (result: AnyObject!, error: NSError?) -> Void){
        var parsedResult: AnyObject!
        do {
            //Remove {skip} characters, 1st 5 chars for Udacity API
            let newData = data.subdataWithRange(NSMakeRange(skip, data.length-skip))
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            //                        print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as json \(data)"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        completionHandler(result: parsedResult, error: nil)
    }
    
    //Performs a GET request
    func taskForGET(baseURL: String,
                    method: String,
                    parameters: [String : AnyObject]?,
                    headerValues: [String: String]?,
                    resultIndex: Int = 0,
                    completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        if let headerValues = headerValues {
            for (header, value) in headerValues {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var statusCode : Int = -1
                var errorDescription : String? = nil
                if let response = response as? NSHTTPURLResponse {
                    errorDescription = "Request returned invalid response. Status \(response.statusCode)"
                    statusCode = response.statusCode
                }
                else if let response = response {
                    errorDescription = "Request returned invalid response. Status \(response)"
                }
                else {
                    errorDescription = "Request returned invalid response."
                }
                completionHandler(result: nil,
                                  error: NSError(domain: "taskForGET",
                                    code: statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: errorDescription!]))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request")
                completionHandler(result: nil, error: NSError(domain: "taskForGET",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No data returned by request"]))
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, skip: resultIndex,  completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    //Performs a POST request
    func taskForPOST(baseURL: String,
                     method: String,
                     parameters: [String : AnyObject]?,
                     headerValues: [String: String]?,
                     jsonBody: [String: AnyObject],
                     resultIndex: Int = 0,
                     completionHandler: (result: AnyObject!, error: NSError?) -> Void )
        -> NSURLSessionDataTask {
            
            /* 2/3 Build URL, configure request */
            let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            if let headerValues = headerValues {
                for (header, value) in headerValues {
                    request.addValue(value, forHTTPHeaderField: header)
                }
            }
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            }
            /* 4 Make request */
            let task = session.dataTaskWithRequest(request){ (data,
                response, error) in
                
                //Guard: Error in request
                guard (error == nil) else {
                    print("There was an error in the request")
                    completionHandler(result: nil, error: error)
                    return
                }
                
                //Guard: Error in http status code
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                    where statusCode >= 200 && statusCode <= 299 else {
                        var statusCode : Int = -1
                        var errorDescription : String? = nil
                        if let response = response as? NSHTTPURLResponse {
                            errorDescription = "Request returned invalid response. Status \(response.statusCode)"
                            statusCode = response.statusCode
                        }
                        else if let response = response {
                            errorDescription = "Request returned invalid response. Status \(response)"
                        }
                        else {
                            errorDescription = "Request returned invalid response."
                        }
                        completionHandler(result: nil,
                                          error: NSError(domain: "taskForPOST",
                                            code: statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: errorDescription!]))
                        return
                }
                
                //Guard: No data returned
                guard let data = data else {
                    print("No data returned by request")
                    completionHandler(result: nil, error: NSError(domain: "taskForPOST",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "No data returned by request"]))
                    return
                }
                
                // 5, 6 Parse and use data
                OTMClient.parseJSONWithCompletionHandler(data, skip: resultIndex, completionHandler: completionHandler)
                
            }
            /* 7 Start request */
            task.resume()
            return task
    }
    
    //Performs a PUT request
    func taskForPUT(baseURL: String,
                     method: String,
                     parameters: [String : AnyObject]?,
                     headerValues: [String: String]?,
                     jsonBody: [String: AnyObject],
                     resultIndex: Int = 0,
                     completionHandler: (result: AnyObject!, error: NSError?) -> Void )
        -> NSURLSessionDataTask {
            
            /* 2/3 Build URL, configure request */
            let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "PUT"
            if let headerValues = headerValues {
                for (header, value) in headerValues {
                    request.addValue(value, forHTTPHeaderField: header)
                }
            }
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            }
            /* 4 Make request */
            let task = session.dataTaskWithRequest(request){ (data,
                response, error) in
                
                //Guard: Error in request
                guard (error == nil) else {
                    print("There was an error in the request")
                    completionHandler(result: nil, error: error)
                    return
                }
                
                //Guard: Error in http status code
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                    where statusCode >= 200 && statusCode <= 299 else {
                        var statusCode : Int = -1
                        var errorDescription : String? = nil
                        if let response = response as? NSHTTPURLResponse {
                            errorDescription = "Request returned invalid response. Status \(response.statusCode)"
                            statusCode = response.statusCode
                        }
                        else if let response = response {
                            errorDescription = "Request returned invalid response. Status \(response)"
                        }
                        else {
                            errorDescription = "Request returned invalid response."
                        }
                        completionHandler(result: nil,
                                          error: NSError(domain: "taskForPUT",
                                            code: statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: errorDescription!]))
                        return
                }
                
                //Guard: No data returned
                guard let data = data else {
                    print("No data returned by request")
                    completionHandler(result: nil, error: NSError(domain: "taskForPUT",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "No data returned by request"]))
                    return
                }
                
                // 5, 6 Parse and use data
                OTMClient.parseJSONWithCompletionHandler(data, skip: resultIndex, completionHandler: completionHandler)
                
            }
            /* 7 Start request */
            task.resume()
            return task
    }
    
    //Peforms a DELETE request
    func taskForDELETE(baseURL: String,
                       method: String,
                       parameters: [String : AnyObject]?,
                       headerValues: [String: String]?,
                       resultIndex: Int = 0,
                       completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 2/3. Build the URL and configure the request */
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        if let headerValues = headerValues {
            for (header, value) in headerValues {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var statusCode : Int = -1
                var errorDescription : String? = nil
                if let response = response as? NSHTTPURLResponse {
                    errorDescription = "Request returned invalid response. Status \(response.statusCode)"
                    statusCode = response.statusCode
                }
                else if let response = response {
                    errorDescription = "Request returned invalid response. Status \(response)"
                }
                else {
                    errorDescription = "Request returned invalid response."
                }
                completionHandler(result: nil,
                                  error: NSError(domain: "taskForGET",
                                    code: statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: errorDescription!]))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request")
                completionHandler(result: nil, error: NSError(domain: "taskForDELETE",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No data returned by request"]))
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, skip: resultIndex,  completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    //Singleton pattern
    static let sharedInstance = OTMClient()
    
}
