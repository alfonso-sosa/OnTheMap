//
//  OTMPostLocationViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 4/26/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * First View Controller to post the user's location. Prompts the user for the location they are studying from and 
 * geocodes it
 */
class OTMPostLocationViewController : UIViewController, UITextViewDelegate, OTMNetworkActivityIndicator {
   
    /**
     * Button to encode and proceed to next step
     */
    @IBOutlet weak var findButton: UIButton!
    
    /**
     * TextView for the user to enter her location
     */
    @IBOutlet weak var locationTextView: UITextView!
    
    /**
     * The result of geocoding
     */
    var placemark : CLPlacemark?
    
    //ActivityIndicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /**
     * Dismisses the operation and goes back to the tab bar view.
     */
    @IBAction func cancelPost(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * Sets up the round submit button.
     */
    override func viewDidLoad() {
        findButton.layer.cornerRadius = 5
        locationTextView.delegate = self
    }
    
    /**
     * Clears the textview's text when editing begins.
     */
    func textViewDidBeginEditing(textView: UITextView) {
        locationTextView.text = ""
    }
    
    /**
     * Dismisses keyboard when done.
     */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let resultRange = text.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: .BackwardsSearch)
        if text.characters.count == 1 && resultRange?.count > 0 {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /**
     * Tries to geocode the textview's text. If the process succeeds, the next ViewController is shown with a segue.
     */
    @IBAction func geocodeLocation(sender: UIButton) {
        if let locationString = locationTextView.text {
            if locationString == "" || locationString == "Enter your location" {
                displayMessage("Missing location", message: "Please enter your location to continue")
                return
            }
            startActivity()
            CLGeocoder().geocodeAddressString(locationString, completionHandler:{(placemarks, error) in
                if let error = error {
                    self.displayError(error.localizedDescription)
                }
                else if let placemarks = placemarks {
                    self.placemark = placemarks.last! as CLPlacemark
                    self.performSegueWithIdentifier("confirmLocationSegue", sender: self)
                }
                self.stopActivity()
            })

        }
        
    }
    
    /**
     * Sets up the next view controller using the geocoded location.
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "confirmLocationSegue" {
            let controller = segue.destinationViewController as! OTMConfirmLocationViewController
            controller.postLocationController = self
            controller.placemark = self.placemark
        }
    }
    
    //Returns the indicator
    func getIndicator() -> UIActivityIndicatorView {
        return activityIndicator
    }
    
}
