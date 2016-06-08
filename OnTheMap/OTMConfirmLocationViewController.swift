//
//  OTMConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 4/29/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/**
 * Second and last step to submit the user's location. Confirms that the geocoding is correct and prompts the user for a url.
 */
class OTMConfirmLocationViewController : UIViewController, UITextViewDelegate, OTMNetworkActivityIndicator {
    
    /**
     * TextView for the url
     */
    @IBOutlet weak var urlTextView: UITextView!
    
    /**
     * Submit button to confirm and finish the process
     */
    @IBOutlet weak var submitButton: UIButton!
    
    /**
     * Reference to presenting VC
     */
    var postLocationController: OTMPostLocationViewController?
    
    /**
     * The placemark result of geocoding in the 1st step
     */
    var placemark : CLPlacemark?
    
    /**
     * Map view
     */
    @IBOutlet weak var mapView: MKMapView!
    
    /**
     * Activity Indicator
     */
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /**
     * Sets up the round submit button.
     */
    override func viewDidLoad() {
        submitButton.layer.cornerRadius = 5
        urlTextView.delegate = self
    }
    
    /**
     * Clears the textview's text when editing begins.
     */
    func textViewDidBeginEditing(textView: UITextView) {
        urlTextView.text = ""
    }
    
    /**
     * Dismisses the operation.
     */
    @IBAction func cancelPost(sender: UIBarButtonItem) {
        dismissPost()
    }
    
    /**
     * Uses the geocoded placemark to center the mapview around it.
     */
    override func viewWillAppear(animated: Bool) {
        if let placemark = placemark {
            //Focus on region surrounding the placemark
            self.mapView.setRegion(
                MKCoordinateRegionMake(
                    CLLocationCoordinate2DMake(
                        (placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!), MKCoordinateSpanMake(0.00725, 0.00725)), animated: true)
            //Creates and adds pin to show the user the geocoded location
            let coordinate = CLLocationCoordinate2D(
                latitude: (placemark.location?.coordinate.latitude)!,
                longitude: (placemark.location?.coordinate.longitude)!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = placemark.locality
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotation)
            })
            
        }
    }

    /**
     * Invokes the Parse API service to submit the user's location.
     */
    @IBAction func submitLocation(sender: UIButton) {
        if let url = urlTextView.text {
            if url == "" || url == "Enter your url" {
                displayMessage("Missing url", message: "Please enter a url to continue")
                return
            }
            //Details of the current user, defaults to empty string if missing.
            let username = OTMClient.sharedInstance().userFirstName ?? ""
            //Service returns 400 when last name is an empty string
            let lastname = OTMClient.sharedInstance().userLastName ?? "n/a"
            let locality = self.placemark?.locality ?? ""
            
            startActivity()
            //Check for previous submissions
            OTMClient.sharedInstance().getUserPostId(OTMClient.sharedInstance().accountKey!){ (success, postId, error) in
                if  success {
                    //Update previously submitted location
                    if let postId = postId {
                        //Double check placemark coordinates
                        if let lat = self.placemark?.location?.coordinate.latitude,
                            long = self.placemark?.location?.coordinate.longitude {
                            //Posts the user's location
                            OTMClient.sharedInstance().updateUserLocation(
                                postId,
                                firstname: username,
                                lastname: lastname,
                                mapString: locality,
                                mediaURL: url,
                                latitude: lat,
                                longitude: long,
                                completionHandler: { (success, errorString) in
                                    if !success {
                                        //Fail, pop up error message
                                        self.displayError(errorString)
                                    }
                                    else {
                                        //OK, dismiss and go back to tab view.
                                        self.dismissPost()
                                        //Post notification
                                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "reload", object: nil))
                                    }
                            })
                        }
                        else {
                            //Let the user know the operation failed
                            self.displayError("Could not retrieve location coordinates")
                        }
                    }
                        //Nothing in server, post new location
                    else {
                        //Double check placemark coordinates
                        if let lat = self.placemark?.location?.coordinate.latitude,
                            long = self.placemark?.location?.coordinate.longitude {
                            //Posts the user's location
                            OTMClient.sharedInstance().postUserLocation(
                                username,
                                lastname: lastname,
                                mapString: locality,
                                mediaURL: url,
                                latitude: lat,
                                longitude: long,
                                completionHandler: { (success, errorString) in
                                    if !success {
                                        //Fail, pop up error message
                                        self.displayError(errorString)
                                    }
                                    else {
                                        //OK, dismiss and go back to tab view.
                                        self.dismissPost()
                                    }
                            })
                        }
                        else {
                            //Let the user know the operation failed
                            self.displayError("Could not retrieve location coordinates")
                        }
                    }
                }
                else {
                    self.displayError(error)
                }
                self.stopActivity()
            }
        }
    }
    
    /**
     * Aborts and goes back to the tab bar view.
     */
    func dismissPost(){
        dispatch_async(dispatch_get_main_queue(), {
            //dismiss this VC
            self.dismissViewControllerAnimated(false, completion: nil)
            //dismiss presenting VC
            if let postLocationController = self.postLocationController {
                postLocationController.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    //Returns the indicator
    func getIndicator() -> UIActivityIndicatorView {
        return activityIndicator
    }
    
}
