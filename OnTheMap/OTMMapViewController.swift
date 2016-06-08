//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Alfonso Sosa on 3/17/16.
//  Copyright © 2016 Alfonso Sosa. All rights reserved.
//

import UIKit
import MapKit


class OTMMapViewController : UIViewController, MKMapViewDelegate {
    
    var mapData : [[String : AnyObject]]?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OTMClient.sharedInstance().getStudentLocations(10, skip: 0, order: "updatedAt"){
            (success, result, errorString) in
            if success {
                var annotations = [MKPointAnnotation]()
                for dictionary in result! {
                    let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                    let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary["firstName"] as! String
                    let last = dictionary["lastName"] as! String
                    let mediaURL = dictionary["mediaURL"] as! String
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    
                    
                    annotations.append(annotation)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapData = result
                    self.mapView.addAnnotations(annotations)
                })
            }
            else {
                self.displayError("Unable to fetch Map Data")
            }
        }
    }
    
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
            }
            return view
        }
        return nil
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Called")
        if control == view.rightCalloutAccessoryView {
            print("control \(control)")
            print("view accessory \(view.rightCalloutAccessoryView)")
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
        else {
            print("no match")
        }
    }
    
    
}