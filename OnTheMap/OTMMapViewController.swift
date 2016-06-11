//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 3/17/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit
import MapKit

//Controller for the map tab view
class OTMMapViewController : UIViewController, MKMapViewDelegate, OTMMapDataPresenter, OTMNetworkActivityIndicator {
    
    //The map view
    @IBOutlet weak var mapView: MKMapView!
    
    //Activity indicator
    var activityIndicator: UIActivityIndicatorView!
    
    //Set up spinner, load data, subscribe to notifications
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView: activityIndicator))
        reloadData({() in
            self.startActivity()
            },
                   after:{() in
                    self.stopActivity()
            }
        )
        subscribeToChangeNotifications()
    }

    //ViewDidUnload is deprecated to unsubscribe from events. Using didReceiveMemoryWarning, as per http://tewha.net/2012/09/dont-write-viewdidunload/
    override func didReceiveMemoryWarning() {
        //Keyboard notifications are no longer necessary
        unsubscribeFromChangeNotifications()
    }

    
    //Creates MKPointAnnotations using the Parse API results and adds them to the map view.
    func refreshUI() {
        var annotations = [MKPointAnnotation]()
        for studentInfo in OTMStudentData.sharedInstance.studentInformationList {
            let coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude, longitude: studentInfo.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(studentInfo.firstName) \(studentInfo.lastName)"
            annotation.subtitle = studentInfo.mediaUrl            
            annotations.append(annotation)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        })
    }
    
    //Creates or reuses an MKMPinAnnotationView to display the information stored in an MKPointAnnotation when it is tapped.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                view.animatesDrop = true
                view.annotation = annotation
            }
            return view
        }
        return nil
        
    }
    
    //When the MKMPinAnnotationView is tapped, the student's link is opened
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
        else {
            print("no match")
        }
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
    
    /**
     * Begins the flow to post student data.
     */
    @IBAction func post(sender: UIBarButtonItem) {
        postLocation()
    }
    
    /*
     *Logs out of the application
     */
    @IBAction func logout(sender: UIBarButtonItem) {
        logout({() in
            self.startActivity()
            },
               after:{() in
                self.stopActivity()
            }
        )
    }
    
    //Returns the activity indicator for protocol / trait
    func getIndicator() -> UIActivityIndicatorView {
        return activityIndicator
    }
    
}