//
//  ViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 1/26/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

class OTMLoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorTextField: UILabel!

    @IBOutlet weak var signUpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureUI()
    }
    

    
    func configureUI(){
        let usernamePaddingView = UIView(frame: CGRectMake(0.0, 0.0, 10.0, 0.0));
        usernameTextField.leftView = usernamePaddingView;
        usernameTextField.leftViewMode = .Always
        
        let passwordPaddingview = UIView(frame: CGRectMake(0.0, 0.0, 10.0, 0.0));
        passwordTextField.leftView = passwordPaddingview;
        passwordTextField.leftViewMode = .Always
        
        signUpLabel.userInteractionEnabled = true
        let tapRecognizer =  UITapGestureRecognizer.init(target: self, action: #selector(LoginViewController.showUdacitySignUp(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        signUpLabel.addGestureRecognizer(tapRecognizer)
        
    }
    
    func showUdacitySignUp(recognizer: UITapGestureRecognizer){
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(url)
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(sender: UIButton) {
        errorTextField.text = ""
        if usernameTextField.text!.isEmpty {
            displayError("Username is empty")
        }
        else if passwordTextField.text!.isEmpty {
            displayError("Password is empty")
        }
        else {
            OTMClient.sharedInstance().authenticateWithCredentials(usernameTextField.text!,
                    password: passwordTextField.text!){ (success, errorString) in
                        if let errorString = errorString {
                            self.displayError(errorString)
                        }
                        else {
                            self.completeLogin()
                        }
            }
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorTextField.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    

}

