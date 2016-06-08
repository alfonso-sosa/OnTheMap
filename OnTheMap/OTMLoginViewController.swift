//
//  ViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 1/26/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

//Initial controller, performs login with user details
class OTMLoginViewController: UIViewController, OTMNetworkActivityIndicator, UITextFieldDelegate {
    
    //Activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Username and password textfields
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Signup label, redirects to Udacity when tapped
    @IBOutlet weak var signUpLabel: UILabel!
    
    //Login button
    @IBOutlet weak var loginButton: UIButton!
    
    var isViewUp: Bool?
    
    
    //Configures UI after load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureUI()
        isViewUp = false
        //Disable autocorrection bars for user and password
        usernameTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
    }
    
    
    //Adds padding to the textfields, and a taprecognizer to the label, subscribe to events
    func configureUI(){
        let usernamePaddingView = UIView(frame: CGRectMake(0.0, 0.0, 10.0, 0.0));
        usernameTextField.leftView = usernamePaddingView;
        usernameTextField.leftViewMode = .Always
        
        let passwordPaddingview = UIView(frame: CGRectMake(0.0, 0.0, 10.0, 0.0));
        passwordTextField.leftView = passwordPaddingview;
        passwordTextField.leftViewMode = .Always
        
        signUpLabel.userInteractionEnabled = true
        let tapRecognizer =  UITapGestureRecognizer.init(target: self, action: #selector(OTMLoginViewController.showUdacitySignUp(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        signUpLabel.addGestureRecognizer(tapRecognizer)

    }
    
    //Subscribe to notifications
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    //Unsubscribe from notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //Keyboard notifications are no longer necessary
        unsubscribeFromKeyboardNotifications()
    }
    
    //Redirects to udacity sign in page
    func showUdacitySignUp(recognizer: UITapGestureRecognizer){
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Tries to authenticate the user with the specified details.
    @IBAction func login(sender: UIButton) {
        if usernameTextField.text!.isEmpty {
            displayError("Username is empty")
        }
        else if passwordTextField.text!.isEmpty {
            displayError("Password is empty")
        }
        else {
            startActivity()
            OTMClient.sharedInstance().authenticateWithCredentials(
                usernameTextField.text!,
                password: passwordTextField.text!){ (success, errorString) in
                    if let errorString = errorString {
                        self.stopActivity()
                        self.displayError(errorString)
                    }
                    else {
                        self.continueLogin()
                    }
            }
        }
    }
    
    //If the login call was successful, tries to get the recent posts and continues the login process
    func continueLogin(){
        OTMClient.sharedInstance().fetchUserPublicData(OTMClient.sharedInstance().accountKey!) { (success, errorString) in
            if let errorString = errorString {
                self.stopActivity()
                self.displayError(errorString)
            }
            else {
                self.completeLogin()
            }
        }
    }
    
    //Shows the application main screen
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.stopActivity()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //Starts spinning
    func startActivity() -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.getIndicator().startAnimating()
            self.loginButton.enabled=false
        })
    }
    
    //Stops spinning
    func stopActivity() -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.getIndicator().stopAnimating()
            self.loginButton.enabled=true
        })
    }

    
    //Returns the activity indicator for protocol / trait
    func getIndicator() -> UIActivityIndicatorView {
        return activityIndicator
    }
    
    //When the user has finished editing (return pressed) the keyboard is dismissed
    //Switches to password when username is done, submits when password is done
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField == usernameTextField){
            passwordTextField.becomeFirstResponder()
        }
        else if (textField == passwordTextField) {
            login(loginButton)
        }
        return true
    }
    
    //Subscribe to keyboard showing or hiding and associating the appropriate methods
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OTMLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OTMLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Unsubscribe from keyboard events
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    //Invoked when the keyboard will appear, shifts the view up by the keyboard height
    func keyboardWillShow(notification: NSNotification) {
        //Raise any textfield, if view is not up already
        if (!isViewUp!){
            isViewUp = true
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //Invoked when the keyboard is dismissed, shifts the view back down
    func keyboardWillHide(notification: NSNotification) {
        //Only lower when password is done and view is up
        if (passwordTextField.isFirstResponder() && isViewUp!){
            isViewUp = false
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //Returns the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
}

