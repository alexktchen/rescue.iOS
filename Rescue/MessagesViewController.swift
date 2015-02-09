//
//  MessagesViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/25.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//


import UIKit
import CoreData
import MapKit

class MessagesViewController: JSQMessagesViewController, CLLocationManagerDelegate{
    
  
    var messages = [Message]()
    var locationManager: CLLocationManager!
    
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    var session: SessionService?
   
    var indicatorView: UIActivityIndicatorView?
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.indicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
        
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

        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName"){
            self.sender = name
            println(self.sender)
            session = SessionService(name: name)
        }
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        
        session?.onReceive { (serializedPost:NSData) -> Void in
            var post = NSKeyedUnarchiver.unarchiveObjectWithData(serializedPost) as Message
            NSNotificationCenter.defaultCenter().postNotificationName("postReceived", object: post)
        }
        
        session?.onBrowsing{()->Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("BrowsingReceived", object: AnyObject?())
        }
        session?.onChangesStatue { (serializedPost:Int) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("ChangesStatusReceived", object: serializedPost)
        }
        
        var timeInterval = NSTimeInterval(1)
        var timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self.session!, selector: Selector("start"), userInfo: nil, repeats: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("notificationWasReceived:"), name: "postReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ChangesStatus:"), name: "ChangesStatusReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("StatusBrowsing:"), name: "BrowsingReceived", object: nil)
        
        
        LoadHistoryMessage()
        
        let barItem: UIBarButtonItem = UIBarButtonItem(customView: self.indicatorView!)
        
        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresConnection")
        let toolbarButtonItems = [refreshButton,barItem]
        
        self.navigationItem.setRightBarButtonItems(toolbarButtonItems, animated: true)
       
        
        self.indicatorView?.startAnimating()
        self.indicatorView?.hidden = true
        self.indicatorView?.hidesWhenStopped = true
        self.indicatorView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    }
    
    func refresConnection(){
        self.indicatorView?.startAnimating()
        self.indicatorView?.hidden = false
        self.indicatorView?.hidesWhenStopped = true

    }
    
    func StatusBrowsing(notification: NSNotification) {
        
        self.navigationController?.navigationBar.topItem?.title = "連線中"
    }
    
    func ChangesStatus(notification: NSNotification) {
        
        delay(0.0) {
            let x : Int = notification.object as Int
            let xNSNumber = x as NSNumber
            let xString : String = xNSNumber.stringValue
            
            self.navigationController?.navigationBar.topItem?.title = "連線人數：" +  xString
            self.indicatorView?.stopAnimating()
            self.indicatorView?.hidesWhenStopped = true
        }
    }
    
    func notificationWasReceived(notification: NSNotification) {
        
        var receuvedMessage = notification.object as Message
        receuvedMessage.received = true
        receuvedMessage.receiver = self.sender
        delay(0.1) {
            self.finishReceivingMessage()
            self.scrollToBottomAnimated(true)
        }
        
        messages.append(receuvedMessage)
        SaveMessage(receuvedMessage)
    }
    
    func receiveMessage(text: String!, sender: String!){
        
        let message = Message()
       
        messages.append(message)

        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = text
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        SaveMessage(message)
    }
    
    func sendMessage(text: String!, sender: String!) {

        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        self.locationManager.location.coordinate.latitude
        
        println("目前位置：lat \(self.locationManager.location.coordinate.latitude) long \(self.locationManager.location.coordinate.longitude)")
        
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate

        let message = Message()
        message.id = NSUUID().UUIDString
        message.text = text
        message.sender = self.sender
        message.sendDateTime = NSDate()
        message.latitude = self.locationManager.location.coordinate.latitude
        message.longitude = self.locationManager.location.coordinate.longitude
        
        if(delegate.reachability.currentReachabilityStatus.hashValue == 0){
            message.uploaded = false
        }
        else{
            DataManager.PostRescueInfo(message)
            message.uploaded = true
            message.uploader = self.sender
            message.uploadDateTime = NSDate()
        }
        
        self.session?.send(message)
        
        self.messages.append(message)
        
        
        SaveMessage(message)
        
        finishReceivingMessage()
        
        scrollToBottomAnimated(true)
    }
    
    func SaveMessage(msg : Message){
        
        let appDelegte = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegte.managedObjectContext
        
        let entiy = NSEntityDescription.entityForName("Messages", inManagedObjectContext: managedContext!)
        
        let object = NSManagedObject(entity: entiy!, insertIntoManagedObjectContext: managedContext)
        object.setValue(msg.text, forKey: "text")
        object.setValue(msg.sender, forKey: "sender")
        object.setValue(msg.sendDateTime, forKey: "sendDateTime")
       
        var error : NSError?
        
        if(managedContext?.save(&error) == nil){
            print(error)
        }
        
    }
    
    func LoadHistoryMessage(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Messages")
        
        var error: NSError?
        let fetchedResults = managedContext?.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults{
            
            for result in results{
                
                var msg: Message = Message()
                msg.text = result.valueForKey("text") as String
                msg.sender = result.valueForKey("sender") as String
                msg.sendDateTime = result.valueForKey("sendDateTime") as NSDate
                messages.append(msg)
            }
        }
        else{
            print(error)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))
            ),dispatch_get_main_queue(), closure)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!){
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        
        let message = messages[indexPath.item]
        
        if message.sender == self.sender{
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        return UIImageView(image: UIImage())
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        
        if message.sender == self.sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item];
        
        return NSAttributedString(string:message.getDateString())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return CGFloat(20)
    }
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!{
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.sender == self.sender {
            return nil
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender == message.sender {
                return nil
            }
        }
        
        return NSAttributedString(string:message.sender)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender == self.sender  {
            return CGFloat(0.0)
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender == message.sender {
                return CGFloat(0.0)
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


