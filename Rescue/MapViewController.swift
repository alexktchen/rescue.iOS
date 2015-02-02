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
      

         /*
        var latitude:CLLocationDegrees = 48.3
        var longitude:CLLocationDegrees = 9.99
        
        var latDelta:CLLocationDegrees=0.01
        var longDeleta:CLLocationDegrees = 0.01
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDeleta)
        
        var churchLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(churchLocation, theSpan)
        
        
        self.mapView.setRegion(theRegion, animated: true)
        
        var theUlmMinsterAnntaion = CustomAnnotation(location: churchLocation)
        //var theUlmMinsterAnntaion = MKPointAnnotation()
        theUlmMinsterAnntaion.coordinate = churchLocation
        theUlmMinsterAnntaion.title = "test"
        theUlmMinsterAnntaion.subtitle = "test"
        
        self.mapView.addAnnotation(theUlmMinsterAnntaion)
 mapView(mapView, viewForAnnotation: theUlmMinsterAnntaion)
        //addLocation(48.3, long: 9.99, title: "123")
       */
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
        
        addLocation(locValue.latitude, long: locValue.longitude, title: "消防局",subTitle: "松山分局")
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
        
        
        
        //annotationArray.append(theUlmMinsterAnntaion)
        self.mapView.addAnnotation(theUlmMinsterAnntaion)

        mapView(mapView, viewForAnnotation: theUlmMinsterAnntaion)
       
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
        
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
   
        var v : CustomAnnotationView! = nil
        
        let ident = "bike"
        
       // v = mapView.dequeueReusableAnnotationViewWithIdentifier(ident)
        
        if v == nil {
            v = CustomAnnotationView(annotation:annotation, reuseIdentifier:ident)
            v.calloutOffset = CGPointMake(0, 0)
            //v = MKAnnotationView(annotation:annotation, reuseIdentifier:ident)
            v.image = UIImage(named: "mapDotNormal")
            v.canShowCallout = true
        }
        else {
            v!.annotation = annotation
        }
        
        v.annotation = annotation
        
        return v

        
    }
}