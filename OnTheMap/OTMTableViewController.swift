//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 4/16/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit

//Controller for the table tab view
class OTMTableViewController : UITableViewController, OTMMapDataPresenter, OTMNetworkActivityIndicator {

    
    //Activity indicator
    var activityIndicator: UIActivityIndicatorView!
    
    
    //Set up spinner, subscribe to notifications
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView: activityIndicator))
        subscribeToChangeNotifications()
    }
    
    //ViewDidUnload is deprecated to unsubscribe from events. Using didReceiveMemoryWarning, as per http://tewha.net/2012/09/dont-write-viewdidunload/
    override func didReceiveMemoryWarning() {
        unsubscribeFromChangeNotifications()
    }
    
    //Refreshes the table data
    func refreshUI() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    //Reloads data
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    //Shows the students' posts in 1 section of the table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Returns the number of rows in the table (1 for each user post in the results)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMStudentData.sharedInstance().studentInformationList.count
    }
    
    //Dequeues and initializes a table cell with the student first and last name, to be displayed at specified indexPath.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("otmTableViewCell") as! OTMTableViewCell
        let studentInfo = OTMStudentData.sharedInstance().studentInformationList[indexPath.row]
        cell.label.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        return cell
    }
    
    //When the row is tapped, the student's link is opened
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let studentInfo = OTMStudentData.sharedInstance().studentInformationList[indexPath.row]
        app.openURL(NSURL(string: studentInfo.mediaUrl)!)
    }
    
    //Reloads students' data
    @IBAction func reload(sender: UIBarButtonItem) {
        reloadData({() in
            self.startActivity()
            },
                   after:{() in
                    self.stopActivity()
            }
        )
    }
    
    //Begins the flow to post student data.
    @IBAction func post(sender: UIBarButtonItem) {
        postLocation()
    }
    
    //Logs out of the application
    @IBAction func logout(sender: UIBarButtonItem) {
        logout({() in
            self.startActivity()
            },
               after:{() in
                self.stopActivity()
            }
        )
    }
    
    //Returns the indicator
    func getIndicator() -> UIActivityIndicatorView {
        return activityIndicator
    }
    
}
