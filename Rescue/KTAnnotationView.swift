//
//  KTAnnotationView.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//
import UIKit
import MapKit

class KTAnnotationView :MKPinAnnotationView{
    
   
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        
        var calloutView:CalloutDirectionsView = CalloutDirectionsView()
        
        
      // var view = calloutView.instanceFromNib()
        
        
        
       // calloutView.addTarget(self, action: "tappedButton:", events: UIControlEvents.TouchUpInside)
       // calloutView.button.addTarget(self, action: "tappedButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let img = UIImage(named: "mapDotNormal")
        self.frame = CGRectMake(0,0,50,50)
        self.centerOffset = CGPointMake(0, -50)
        self.opaque = false
        self.image = img
        
        var imageview = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        imageview.image = UIImage(named: "LocationDirectionButton")
        self.leftCalloutAccessoryView = calloutView.instanceFromNib()
       // calloutView.setText("123")

    }
    
    func tappedButton(sender: UIButton!){
        println("tapped button")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
