//
//  MapViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var annotationArray = [MKAnnotation]()
    
    @IBAction func locate(sender: AnyObject) {
        
       getCurrentLocation()        
    }
    
    
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
      
        DataManager.getHelpInfos { (lat,long,name,tel) -> Void in
            
             self.addLocation(lat, long: long,title: name,subTitle: tel)
        }
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

        mapView(mapView, viewForAnnotation: theUlmMinsterAnntaion)
       
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
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
            point.image = UIImage(named: "mapDotNormal")
            point.canShowCallout = true
        }
        else {
            point!.annotation = annotation
        }
        
        point.annotation = annotation
        
        return point

        
    }
}