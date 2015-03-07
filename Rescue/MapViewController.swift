//
//  MapViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var annotationArray = [MKAnnotation]()
    
    @IBAction func locate(sender: AnyObject) {
        
        getCurrentLocation()
    }
    
    // var locationsMutableArray: NSMutableArray?
    var locationsArray: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        //self.mapView.addAnnotation(theUlmMinsterAnntaion)
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
        else{
            println("Location service disabled");
        }
        
        mapView.showsUserLocation = true
        
        
        
        // self.locationsMutableArray = NSMutableArray()
        
        DataManager.getRescueInfo { (locations) -> Void in
            
            self.delay(0.0) {
                
                for location in locations{
                    
                    self.locationsArray.append(location as Location)
                    
                    self.addLocation((location as Location).lat, long: (location as Location).long,title: (location as Location).name,subTitle: (location as Location).tel)
                }
            }
        }
        
        DataManager.getHelpInfos { (locations) -> Void in
            
            //self.locationsMutableArray = locations as NSMutableArray
            
            self.delay(0.0) {
                
                for location in locations{
                    self.locationsArray.append(location as Location)
                    
                    self.addLocation((location as Location).lat, long: (location as Location).long,title: (location as Location).name,subTitle: (location as Location).tel)
                }
                
                
            }
        }
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))
            ),dispatch_get_main_queue(), closure)
    }
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        let views = [
            "map": mapView
        ]
        let metrics = [
            "padding": 0
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[map]-padding-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[map]-padding-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var locValue : CLLocationCoordinate2D = manager.location.coordinate
        let span2 = MKCoordinateSpanMake(1, 1)
        let long = locValue.longitude
        let lat = locValue.latitude
        
        let loadlocation = CLLocationCoordinate2D(
            latitude: lat, longitude: long
            
        )
        mapView.centerCoordinate = loadlocation;
        locationManager.stopUpdatingLocation();
        let userLocation = mapView.userLocation
        
    }
    
    func getCurrentLocation(){
        
        let userLocation = mapView.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func addLocation(lat:Double, long:Double, title:String, subTitle: String){
        var latitude:CLLocationDegrees = lat
        var longitude:CLLocationDegrees = long
        var churchLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var theUlmMinsterAnntaion = MKPointAnnotation()
        theUlmMinsterAnntaion.coordinate = churchLocation
        theUlmMinsterAnntaion.title = title
        theUlmMinsterAnntaion.subtitle = subTitle
        self.mapView.addAnnotation(theUlmMinsterAnntaion)
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       var viewControl = storyboard.instantiateViewControllerWithIdentifier("RescuePhotoView") as? RescuePhotoView
        viewControl?.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        
        viewControl?.photoUrl = NSURL(string: view.annotation.subtitle!)

        
        let popoverPresentationViewController = viewControl?.popoverPresentationController
        popoverPresentationViewController?.permittedArrowDirections = .Any
        popoverPresentationViewController?.delegate = self
        popoverPresentationController?.sourceRect = self.view.frame
        presentViewController(viewControl!, animated: true, completion: nil)
        
        
      
        
        /*
        let imageView: UIImageView = UIImageView()
        
        
        if let url = NSURL(string: view.annotation.subtitle!) {
            
            if let data = NSData(contentsOfURL: url){
                
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
                view.addSubview(imageView)
            }
        }
*/

       
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var point : CustomAnnotationView! = nil
        
        let ident = "helpinfo"
        
        if point == nil {
            
            point = CustomAnnotationView(annotation:annotation, reuseIdentifier:ident)
            point.calloutOffset = CGPointMake(0, 0)
            point.canShowCallout = true
            
            for var index = 0; index < self.locationsArray.count; ++index {
                
                if(self.locationsArray[index].lat == annotation.coordinate.latitude && self.locationsArray[index].long == annotation.coordinate.longitude){
                    
                    if(self.locationsArray[index].type == 0){
                        point.image = UIImage(named: "mapblueDotNormal")
                    }
                    else{
                        if(!self.locationsArray[index].tel.isEmpty){
                            /*
                            let imageView: UIImageView = UIImageView()
                            
                            if let url = NSURL(string: self.locationsArray[index].tel) {
                                
                                if let data = NSData(contentsOfURL: url){
                                    
                                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                                    imageView.image = UIImage(data: data)
                                    point.rightCalloutAccessoryView = imageView
                                }
                            }
*/
                            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
                            point.rightCalloutAccessoryView = calloutButton
                        }

                        point.image = UIImage(named: "mapDotNormal")
                    }
                }
                
            }
            
            
        }
        else {
            point!.annotation = annotation
        }
        
        point.annotation = annotation
        
        return point
        
        
    }
    
    
}