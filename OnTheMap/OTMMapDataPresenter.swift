//
//  OTMMapDataPresenter.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 4/18/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

//Protocol implemented by the views that will display sutents' posts
protocol OTMMapDataPresenter {
    
    //Reload the data (Make a new request to the Parse API)
    func reloadData(before: ()->Void, after: ()->Void) -> Void

    //Refreshes the UI with the students' information from the OTMStudentData singleton
    func refreshUI() -> Void
    
    //Begins the Location submission process.
    func postLocation() -> Void

    //Logs out of the system
    func logout(before: ()->Void, after: ()->Void) -> Void
    
}

/**
 * Partial implementation of the protocol for the UIViewControllers that display students' posts.
 */
extension OTMMapDataPresenter where Self: UIViewController {
    
    /**
     * Requests data from Parse API, stores it in singleton and performs a UI refresh.
     * before and after callbacks are used for activity indicator
     */
    func reloadData(before:()->Void, after: ()->Void) -> Void {
        before()
        OTMClient.sharedInstance().getStudentLocations(10, skip: 0, order: "updatedAt"){
            (success, results, errorString) in
            if let results = results where results.count > 0 {
                OTMStudentData.sharedInstance().studentInformationList.removeAll()
                OTMStudentData.sharedInstance().studentInformationList.appendContentsOf(results)
                self.refreshUI()
            }
            else {
                self.displayError("Unable to fetch Map Data \(errorString)")
            }
            after()
        }
    }
    
    /**
     * Performs a logout using the Udacity Api.
     * before and after callbacks are used for activity indicator.
     */
    func logout(before: ()->Void, after: ()->Void) {
        before()
        OTMClient.sharedInstance().logout { (success, result, errorString) in
            if success {
                self.completeLogout()
            }
            else {
                self.displayError("Unable to log out. Please try again.")
            }
        }
        after()
    }
    
    /**
     * Presents the login view after logging out.
     */
    func completeLogout() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! OTMLoginViewController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    /**
     * Presents the first View in the workflow to post the user's location.
     */
    func postLocation(){
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("postLocationViewController") as! OTMPostLocationViewController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //Subscribe to keyboard showing or hiding and associating the appropriate methods
    func subscribeToChangeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(OTMMapViewController.reload(_:)),
                                                         name: "reload", object: nil)
    }
    
    //Unsubscribe from keyboard events
    func unsubscribeFromChangeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reload", object: nil)
    }
    
}