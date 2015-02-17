//
//  SendCardViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/16.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit

class SendCardViewController: UIViewController, KSCardViewDelegate{
    
    var cardView: KSCardView?
    
    @IBAction func backTouchDown(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    
 
        self.view.backgroundColor = .clearColor()
        
        let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visuaEffectView.frame = self.view.bounds
        visuaEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        visuaEffectView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.view.addSubview(visuaEffectView)
        

        
        let messageSendView: MessageSendView = MessageSendView(frame: CGRectMake(0, 0, 287, 251))
        
        KSCardView.setCardViewFrame(CGRectMake((self.view.frame.width/2) - (287/2), (self.view.frame.height/2) - (251/2), 287, 251))
        
        var cardView: KSCardView = KSCardView()
       // cardView.backgroundColor = UIColor.clearColor()
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        cardView.addSubview(messageSendView)
        self.view.addSubview(cardView)
        //self.view.backgroundColor = UIColor.clearColor()
        
      //  self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
       // self.view.backgroundColor = UIColor.lightGrayColor()
        addButton()
      

    }
    
    override func viewDidAppear(animated: Bool) {
        //self.view.backgroundColor = UIColor.clearColor()
    }
    

    func cardDidLeaveBottomEdge(cardView: KSCardView!) {
       
    }
    func cardDidLeaveLeftEdge(cardView: KSCardView!) {
        
    }
    func cardDidLeaveRightEdge(cardView: KSCardView!) {
        
    }
    func cardDidLeaveTopEdge(cardView: KSCardView!) {
        
    }
    
    
    func backButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoButtonPressed(){
        var cardView: KSCardView = KSCardView()
        cardView.backgroundColor = UIColor.clearColor()
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        
        let messageSendView: MessageSendView = MessageSendView(frame: CGRectMake(0, 0, 287, 251))
        
        cardView.addSubview(messageSendView)
       
        cardView.showFromLeft()
        self.view.addSubview(cardView)
    }
    
    func addButton(){
        
       var radius = CGFloat(0.5 * 50.0)
        var bottomPosition = self.view.frame.height-70
        
        
     
            
        
        var backbutton = UIButton.buttonWithType(.Custom) as UIButton
        backbutton.frame = CGRectMake(20, 30, 50, 50)
        backbutton.layer.cornerRadius = radius
        backbutton.backgroundColor = UIColor.clearColor()
        
        backbutton.layer.borderWidth = 1
        backbutton.layer.borderColor = UIColor.whiteColor().CGColor
        
        backbutton.setImage(UIImage(named:"backButton"), forState: .Normal)
        backbutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(backbutton)
        
        
        
        var photobutton = UIButton.buttonWithType(.Custom) as UIButton
        photobutton.frame = CGRectMake(20, bottomPosition, 50, 50)
        photobutton.layer.cornerRadius = radius
        photobutton.backgroundColor = UIColor.lightGrayColor()
        photobutton.setImage(UIImage(named:"cameraButton"), forState: .Normal)
        photobutton.addTarget(self, action: "photoButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(photobutton)
        
        var msgbutton = UIButton.buttonWithType(.Custom) as UIButton
        msgbutton.frame = CGRectMake(80, bottomPosition, 50, 50)
        msgbutton.layer.cornerRadius = radius
        msgbutton.backgroundColor = UIColor.lightGrayColor()
        msgbutton.setImage(UIImage(named:"backButton"), forState: .Normal)
        msgbutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(msgbutton)
        
        var recordebutton = UIButton.buttonWithType(.Custom) as UIButton
        recordebutton.frame = CGRectMake(130, bottomPosition, 50, 50)
        recordebutton.layer.cornerRadius = radius
        recordebutton.backgroundColor = UIColor.lightGrayColor()
        recordebutton.setImage(UIImage(named:"backButton"), forState: .Normal)
        recordebutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(recordebutton)
        
        var videobutton = UIButton.buttonWithType(.Custom) as UIButton
        videobutton.frame = CGRectMake(180, bottomPosition, 50, 50)
        videobutton.layer.cornerRadius = radius
        videobutton.backgroundColor = UIColor.lightGrayColor()
        videobutton.setImage(UIImage(named:"backButton"), forState: .Normal)
        videobutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(videobutton)
    }
    
    
}