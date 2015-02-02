//
//  KTAnnotationView.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//
import UIKit
import MapKit

class CustomAnnotationView :MKPinAnnotationView{
    
    
    var calloutView: CalloutDirectionsView?
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        

        let Arrowimageimage = UIImage(named: "calloutDirectionsArrow") as UIImage?
        
        var button: UIButton = UIButton()
        button.addTarget(self, action: "tappedButton:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 48, 48)
        button.setImage(Arrowimageimage, forState: UIControlState.Normal)
        
        var leftView: UIView = UIView(frame: CGRectMake(0, 0, 48, 48))
        leftView.backgroundColor = UIColor(red: 0/255, green: 163/255, blue: 68/255, alpha: 1)
        
        leftView.addSubview(button)
        self.leftCalloutAccessoryView = leftView
        
    }
    
   
    func tappedButton(sender: UIButton!){
        
        
        var add = "q="
        add += String(format:"%f", self.annotation.coordinate.latitude)
        add += ","
        add += String(format:"%f", self.annotation.coordinate.longitude)
        
        
       // if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                "http://maps.apple.com/map?"+add)!)
       // } else {
            NSLog("Can't use comgooglemaps://");
       // }
        println("tapped button")
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
