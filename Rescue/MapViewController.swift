//
//  MapViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController ,MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var latitude:CLLocationDegrees = 48.3
        var longitude:CLLocationDegrees = 9.99
        
        var latDelta:CLLocationDegrees=0.01
        var longDeleta:CLLocationDegrees = 0.01
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDeleta)
        
        var churchLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(churchLocation, theSpan)
        
    
        self.mapView.setRegion(theRegion, animated: true)
        
        var theUlmMinsterAnntaion = KTAnnotation(location: churchLocation)
        theUlmMinsterAnntaion.coordinate = churchLocation
        theUlmMinsterAnntaion.title = "test"
        theUlmMinsterAnntaion.subtitle = "test"
               self.mapView.addAnnotation(theUlmMinsterAnntaion)
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        
        var v : MKAnnotationView! = nil
        
        if annotation is KTAnnotation {
            let ident = "bike"
            v = mapView.dequeueReusableAnnotationViewWithIdentifier(ident)
            if v == nil {
                v = KTAnnotationView(annotation:annotation, reuseIdentifier:ident)
                
                   v!.canShowCallout = true

                
            }
            v.annotation = annotation
        }
        return v
/*
       
        if annotation is MKUserLocation{
            return nil
        }

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? KTAnnotationView
        
        if pinView == nil{
            pinView = KTAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Purple
  
        }
        else{
            pinView?.annotation = annotation
        }
        
        return pinView
*/
    }
}