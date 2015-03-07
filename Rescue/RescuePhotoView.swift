//
//  File.swift
//  Rescue
//
//  Created by Alex Chen on 2015/3/4.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit

class RescuePhotoView: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photoUrl: NSURL?
    
    override func viewDidLoad(){
         super.viewDidLoad()
        addButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        delay(0.0) {

            if let data = NSData(contentsOfURL: self.photoUrl!){
                
                self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.imageView.image = UIImage(data: data)
                
            }
        
        }
        
        view.addSubview(self.imageView)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))
            ),dispatch_get_main_queue(), closure)
    }
    
    func backButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButton(){
        
        var radius = CGFloat(0.5 * 45.0)
        var bottomPosition = self.view.frame.height-70
        var largeradius = CGFloat(0.5 * 60)
        
        let srceenWidth = self.view.frame.width / 4
        
        
        
        var backbutton = UIButton.buttonWithType(.Custom) as UIButton
        backbutton.frame = CGRectMake(10, 20, 45, 45)
        backbutton.layer.cornerRadius = radius
        backbutton.backgroundColor = UIColor.clearColor()
        backbutton.layer.borderWidth = 1
        backbutton.layer.borderColor = UIColor.lightGrayColor().CGColor
        backbutton.setImage(UIImage(named:"cancelButton"), forState: .Normal)
        backbutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(backbutton)
    }


}