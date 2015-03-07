//
//  SendCardViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/16.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



class SendCardViewController: UIViewController, KSCardViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate{
    
    var imagePicker:UIImagePickerController?
    var cardView: KSCardView?
    var messageSendView: MessageSendView?
    var photoSendView: PhotoSendView?
    var session: SessionService?
    
    var avatarViews:NSMutableArray = NSMutableArray()
    var msgbutton: UIButton?
    var photobutton: UIButton?
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
       
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
        else{
            println("Location service disabled");
        }
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker = UIImagePickerController()
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker!.allowsEditing = false
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName"){
            session = SessionService(name: name)
            session?.startAdvertising()
        }
        
        
        session?.onConnected { (serializedPost:String) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("onConnected", object: serializedPost)
        }
        
        session?.onNotConnected { (serializedPost:String) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("onNotConnected", object: serializedPost)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("Connected:"), name: "onConnected", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("NotConnected:"), name: "onNotConnected", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        self.view.backgroundColor = .clearColor()
        
        let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visuaEffectView.frame = self.view.bounds
        visuaEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        visuaEffectView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.view.addSubview(visuaEffectView)
        
        KSCardView.setCardViewFrame(CGRectMake((self.view.frame.width/2) - (287/2), (self.view.frame.height/2) - (251/2), 287, 200))
        
        addButton()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))
            ),dispatch_get_main_queue(), closure)
    }
    
    func NotConnected(notification: NSNotification) {
        delay(0.0) {
            
            for view in self.avatarViews {
                view.removeFromSuperview()
            }
            self.avatarViews.removeAllObjects()
            self.msgbutton?.enabled = false
            self.photobutton?.enabled = false
        }
    }
    
    func Connected(notification: NSNotification) {
        delay(0.0) {
            
            let avatar = AvatarView(frame: CGRectMake(50, 40, 50, 50))
            
            avatar.userNameLabel.text = notification.object as? String
            
            self.avatarViews.addObject(avatar)
            self.view.addSubview(avatar)
            
            self.msgbutton?.enabled = true
            self.photobutton?.enabled = true
            
            
            
        }
    }
    
    func send(sender: UIButton!){
        self.session?.send(self.messageSendView!.text.text)
    }
    func cancel(sender:UIButton!){
        self.cardView?.hideToBtoom()
        removeCard()
    }
    func cardDidShowFromBottom(cardView: KSCardView!) {
        
    }
    func cardDidLeaveBottomEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveLeftEdge(cardView: KSCardView!) {
        
    }
    
    func cardDidLeaveRightEdge(cardView: KSCardView!) {
        
    }
    
    func removeCard(){
        for view in self.view.subviews{
            
            if(view as? NSObject == self.cardView){
                view.removeFromSuperview()
            }
            
        }
    }
    
    func cardDidLeaveTopEdge(cardView: KSCardView!) {
        removeCard()
        //self.session?.send(self.messageSendView!.text.text)
    }
    
    func cardDidReset(cardView: KSCardView!) {
        // self.messageSendView!.text.becomeFirstResponder()
    }
    
    func cardTouchNoMove(cardView: KSCardView!) {
        self.messageSendView!.text.becomeFirstResponder()
        self.cardView?.moveWhenShowKeyboard()
    }
    
    func backButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.session?.disconnect()
    }
    
    @IBAction func backTouchDown(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tap(sender: AnyObject) {
        self.view.endEditing(true);
        self.cardView?.moveWhenHideKeyboard()
    }
    
    func keyboardNotification(notification: NSNotification) {
        self.cardView?.moveWhenShowKeyboard()
    }
    
    func messageButtonPressed(){
        
        self.messageSendView = MessageSendView(frame: CGRectMake(0, 0, 287, 200))
        self.messageSendView!.text.text = "SOS"
        self.cardView = KSCardView()
        self.cardView?.delegate = self
        self.cardView?.layer.cornerRadius = 10
        self.cardView?.layer.masksToBounds = true
        self.cardView?.addSubview(self.messageSendView!)
        self.view.addSubview(self.cardView!)
        self.cardView?.showFromBottom()
        
        
        
        delay(1.5) {
            self.leave()
            self.sendMessage()
        }
    }
    
    func sendMessage(){
        
        let mlat =  self.locationManager.location.coordinate.latitude
        let mlong =  self.locationManager.location.coordinate.longitude
        
        
        let mseeage: MessageCard = MessageCard(latitude: mlat, longitude: mlong,text: self.messageSendView!.text.text)
        
        self.session?.sendCard(mseeage)
    }
    
    func reduceImageSize(image:UIImage) -> UIImage{
        
        let width = CGImageGetWidth(image.CGImage) / 2 / 2 / 2
        let height = CGImageGetHeight(image.CGImage) / 2 / 2 / 2
        let bitsPerComponent = CGImageGetBitsPerComponent(image.CGImage)
        let bytesPerRow = CGImageGetBytesPerRow(image.CGImage)
        let colorSpace = CGImageGetColorSpace(image.CGImage)
        let bitmapInfo = CGImageGetBitmapInfo(image.CGImage)
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image.CGImage)
        return UIImage(CGImage: CGBitmapContextCreateImage(context), scale: CGFloat(0.5), orientation: UIImageOrientation.Right)!
    }
    
    func photoButtonPressed(){
        
        self.presentViewController(imagePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let width = CGImageGetWidth(image.CGImage)
        let height = CGImageGetHeight(image.CGImage)
        
        let scaledImage = reduceImageSize(image)
        
        self.photoSendView = PhotoSendView(frame: CGRectMake(0, 0,CGFloat(width) , CGFloat(height)))
        self.photoSendView?.imageView.image = scaledImage
        self.cardView = KSCardView()
        self.cardView?.delegate = self
        self.cardView?.layer.cornerRadius = 10
        self.cardView?.layer.masksToBounds = true
        self.cardView?.addSubview(self.photoSendView!)
        self.view.addSubview(self.cardView!)
        self.cardView?.showFromBottom()
        
        delay(1.5) {
            self.leave()
            self.sendPhoto()
            
        }
    }
    
    func sendPhoto(){
        
        let mlat =  self.locationManager.location.coordinate.latitude
        let mlong =  self.locationManager.location.coordinate.longitude
        let image = self.photoSendView?.imageView.image
        let mseeage: MessageCard = MessageCard(image: image!, latitude: mlat, longitude: mlong)
        self.session?.sendCard(mseeage)
    }
    
    func leave(){
        self.cardView?.hideToTop()
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
        
        
        self.msgbutton = UIButton.buttonWithType(.Custom) as? UIButton
        self.msgbutton?.frame = CGRectMake(20, bottomPosition, 60, 60)
        self.msgbutton?.layer.cornerRadius = largeradius
        self.msgbutton?.backgroundColor = UIColor.clearColor()
        self.msgbutton?.layer.borderWidth = 1
        self.msgbutton?.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.msgbutton?.setImage(UIImage(named:"commentsButton"), forState: .Normal)
        self.msgbutton?.addTarget(self, action: "messageButtonPressed", forControlEvents: .TouchUpInside)
        self.msgbutton?.enabled = false
        
        self.view.addSubview(self.msgbutton!)
        
        
        
        
        self.photobutton = UIButton.buttonWithType(.Custom) as? UIButton
        self.photobutton?.frame = CGRectMake(self.view.frame.width-80, bottomPosition, 60, 60)
        self.photobutton?.layer.cornerRadius = largeradius
        self.photobutton?.backgroundColor = UIColor.clearColor()
        self.photobutton?.layer.borderWidth = 1
        self.photobutton?.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.photobutton?.setImage(UIImage(named:"photoButton"), forState: .Normal)
        self.photobutton?.addTarget(self, action: "photoButtonPressed", forControlEvents: .TouchUpInside)
        self.photobutton?.enabled = false
        self.view.addSubview(self.photobutton!)
        
        
        var recordebutton = UIButton.buttonWithType(.Custom) as UIButton
        recordebutton.frame = CGRectMake(170, bottomPosition, 60, 60)
        recordebutton.layer.cornerRadius = largeradius
        recordebutton.backgroundColor = UIColor.clearColor()
        recordebutton.layer.borderWidth = 1
        recordebutton.layer.borderColor = UIColor.lightGrayColor().CGColor
        recordebutton.setImage(UIImage(named:"microphoneButton"), forState: .Normal)
        recordebutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        // self.view.addSubview(recordebutton)
        
        
        var videobutton = UIButton.buttonWithType(.Custom) as UIButton
        videobutton.frame = CGRectMake(250, bottomPosition, 60, 60)
        videobutton.layer.cornerRadius = largeradius
        videobutton.backgroundColor = UIColor.clearColor()
        videobutton.layer.borderWidth = 1
        videobutton.layer.borderColor = UIColor.lightGrayColor().CGColor
        videobutton.setImage(UIImage(named:"videoButton"), forState: UIControlState.Normal)
        videobutton.addTarget(self, action: "backButtonPressed", forControlEvents: .TouchUpInside)
        
        // self.view.addSubview(videobutton)
    }
    
    
}