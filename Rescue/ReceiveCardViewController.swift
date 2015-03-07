//
//  ReceiveCardViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/20.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit

class ReceiveCardViewController: UIViewController, KSCardViewDelegate, SearchIndicatorDelegate{
    
    var session: SessionService?
    var cardView: KSCardView?
    var avatarViews:NSMutableArray = NSMutableArray()
    var indicator: SearchIndicator?
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
                
        self.view.backgroundColor = .clearColor()
        
        let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visuaEffectView.frame = self.view.bounds
        visuaEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        visuaEffectView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.view.addSubview(visuaEffectView)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName"){
            session = SessionService(name: name)
           
        }
        
        session?.onBrowsing{()->Void in
            NSNotificationCenter.defaultCenter().postNotificationName("BrowsingReceived", object: AnyObject?())
        }
        
        session?.onReceive { (serializedPost:NSData) -> Void in
            var post = NSKeyedUnarchiver.unarchiveObjectWithData(serializedPost) as MessageCard
            NSNotificationCenter.defaultCenter().postNotificationName("postReceived", object: post)
        }
        
        session?.onChangesStatue { (serializedPost:Int) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("ChangesStatusReceived", object: serializedPost)
        }
        
        session?.onConnected { (serializedPost:String) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("onConnected", object: serializedPost)
        }
        
        session?.onNotConnected { (serializedPost:String) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("onNotConnected", object: serializedPost)
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("StatusBrowsing:"), name: "BrowsingReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("notificationWasReceived:"), name: "postReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ChangesStatus:"), name: "ChangesStatusReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("Connected:"), name: "onConnected", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("NotConnected:"), name: "onNotConnected", object: nil)
        
        addButton()
        
        indicator = SearchIndicator(frame: CGRectMake(self.view.frame.width/2, self.view.frame.height/2, 60, 60))
        indicator?.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.addSubview(indicator!)
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))
            ),dispatch_get_main_queue(), closure)
    }
    
    func NotConnected(notification: NSNotification) {
        delay(0.0) {
            
            self.session?.stopBrowsing()
            
            if ((self.indicator?.isSearching) == true){
                
                self.session?.startBrowsing()
            }
            else{

                for view in self.view.subviews{
                    
                    if(view as? NSObject == self.cardView){
                        view.removeFromSuperview()
                    }
                    
                }
                
                for view in self.avatarViews {
                    view.removeFromSuperview()
                }
                
                self.avatarViews.removeAllObjects()
                self.view.addSubview(self.indicator!)
            }
            
           
        }
    }
    
    func Connected(notification: NSNotification) {
        delay(0.0) {
         
            let avatar = AvatarView(frame: CGRectMake(50, 40, 50, 50))
            
            avatar.userNameLabel.text = notification.object as? String
            
            self.avatarViews.addObject(avatar)
            self.view.addSubview(avatar)
            
            self.indicator?.removeFromSuperview()
        }
    }
    
    
    func ChangesStatus(notification: NSNotification) {
        
        delay(0.0) {
            let x : Int = notification.object as Int
            let xNSNumber = x as NSNumber
            let xString : String = xNSNumber.stringValue
        }
    }
    
    func notificationWasReceived(notification: NSNotification) {
        
        var receuvedMessage = notification.object as MessageCard
        
        delay(0.1) {
            
           
            KSCardView.setCardViewFrame(CGRectMake((self.view.frame.width/2) - (287/2), (self.view.frame.height/2) - (251/2), 287, 200))
            
            self.cardView = KSCardView()
            self.cardView?.backgroundColor = UIColor.clearColor()
            self.cardView?.layer.cornerRadius = 10
            self.cardView?.layer.masksToBounds = true
            
            
            
                       
            if receuvedMessage.type == 2{
                
                let photoSendView: PhotoSendView = PhotoSendView(frame: CGRectMake(0, 0, 287, 251))
                photoSendView.imageView.image = receuvedMessage.image
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                hud.labelText = "上傳中"
                
                hud.mode = MBProgressHUDModeAnnularDeterminate
                
                let service: StorageService = StorageService()
                
                service.uploadImage(receuvedMessage.image, hud: hud, completion:{(url) in
                    
                    self.cardView?.addSubview(photoSendView)
                    DataManager.PostRescueInfo(receuvedMessage.latitude, long: receuvedMessage.longitude, photourl: url)
                    hud.hide(true)
                })
                
                

            }
            else{
                
                DataManager.PostRescueInfo(receuvedMessage.latitude, long: receuvedMessage.longitude, photourl: "")
                let messageSendView: MessageSendView = MessageSendView(frame: CGRectMake(0, 0, 287, 251))
                messageSendView.text.text = receuvedMessage.text
                self.cardView?.addSubview(messageSendView)
            }

            
            self.cardView?.showFromTop()
            self.view.addSubview(self.cardView!)
        }
    }
    
    
    func didStartSearchIndicator() {
        self.session?.startBrowsing()
    }
    
    func didStopSearchIndicator() {
        self.session?.stopBrowsing()
    }
    
    func StatusBrowsing(notification: NSNotification) {
        
        
    }
    
    
    func cardDidShowFromBottom(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveBottomEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveLeftEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveRightEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveTopEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidReset(cardView: KSCardView!) {
        // self.messageSendView!.text.becomeFirstResponder()
    }
    
    func cardTouchNoMove(cardView: KSCardView!) {
        
    }
    
    func backButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.session?.disconnect()
    }
    
    func addButton(){
        
        var radius = CGFloat(0.5 * 45.0)
        var bottomPosition = self.view.frame.height-70
        var largeradius = CGFloat(0.5 * 60)
        
        let srceenWidth = self.view.frame.width / 4
        
        
        
        var backbutton = UIButton.buttonWithType(.Custom) as UIButton
        backbutton.frame = CGRectMake(10, 40, 45, 45)
        backbutton.layer.cornerRadius = radius
        backbutton.backgroundColor = UIColor.clearColor()
        backbutton.layer.borderWidth = 1
        backbutton.layer.borderColor = UIColor.lightGrayColor().CGColor
        backbutton.setImage(UIImage(named:"cancelButton"), forState: .Normal)
        backbutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(backbutton)
    }
}