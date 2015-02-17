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
import AVFoundation

class MessagesViewController: JSQMessagesViewController, CLLocationManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate{
    
    var imagePicker:UIImagePickerController?
    
    var messages:NSMutableArray = NSMutableArray()
    
    var locationManager: CLLocationManager!
    
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    
    
    var session: SessionService?
    
    var indicatorView: UIActivityIndicatorView?
    
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker = UIImagePickerController()
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker!.allowsEditing = false
        }
        
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
            
            self.senderDisplayName = name
            self.senderId = UIDevice.currentDevice().identifierForVendor.UUIDString
            
            println(self.senderDisplayName)
            
            session = SessionService(name: name)
        }
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        
        session?.onReceive { (serializedPost:NSData) -> Void in
            var post = NSKeyedUnarchiver.unarchiveObjectWithData(serializedPost) as JSQMessage
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
        
        
        //LoadHistoryMessage()
        
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
        
        var receuvedMessage = notification.object as JSQMessage
        
        println("received from : " + receuvedMessage.senderDisplayName)
        
        if(receuvedMessage.isMediaMessage){
            let jsqMessadata = receuvedMessage.media as JSQMessageMediaData
            
            if(jsqMessadata is JSQPhotoMediaItem){
                let jsqPhoto = jsqMessadata as JSQPhotoMediaItem
                
                jsqPhoto.appliesMediaViewMaskAsOutgoing = false
            }
            
        }
        
        
        // receuvedMessage.received = true
        //receuvedMessage.receiver = self.senderDisplayName
        messages.addObject(receuvedMessage)
        delay(0.1) {
            self.finishReceivingMessage()
            self.scrollToBottomAnimated(true)
        }
        
        //messages.append(receuvedMessage)
        //SaveMessage(receuvedMessage)
    }
    
    func receiveMessage(text: String!, sender: String!){
        
        let message = Message()
        
        messages.addObject(message)
        
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = text
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //SaveMessage(message)
    }
    
    func sendMessage(text: String!, sender: String!) {
        
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        self.locationManager.location.coordinate.latitude
        
        println("目前位置：lat \(self.locationManager.location.coordinate.latitude) long \(self.locationManager.location.coordinate.longitude)")
        
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)

        // message.id = NSUUID().UUIDString
        // message.sendDateTime = NSDate()
        // message.latitude = self.locationManager.location.coordinate.latitude
        // message.longitude = self.locationManager.location.coordinate.longitude
        
        if(delegate.reachability.currentReachabilityStatus.hashValue == 0){
            // message.uploaded = false
        }
        else{
            // DataManager.PostRescueInfo(message)
            //message.uploaded = true
            //message.uploader = self.senderDisplayName
            //message.uploadDateTime = NSDate()
        }
        
        self.session?.send(message)
        
        self.messages.addObject(message)
        
        
        //SaveMessage(message)
        
        finishReceivingMessage()
        
        scrollToBottomAnimated(true)
    }
    /*
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
    */
    /*
    func LoadHistoryMessage(){
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Messages")
    
    var error: NSError?
    let fetchedResults = managedContext?.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    
    if let results = fetchedResults{
    
    for result in results{
    
    var msg: Message = Message(
    senderId: result.valueForKey("sender") as String,
    displayName: result.valueForKey("sender") as String,
    text: result.valueForKey("text") as String)
    
    //  msg.text = result.valueForKey("text") as String
    // msg.sender = result.valueForKey("sender") as String
    ///  msg.sendDateTime = result.valueForKey("sendDateTime") as NSDate
    messages.addObject(msg)
    }
    }
    else{
    print(error)
    }
    }
    */
    
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
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text, sender: senderDisplayName)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let sheet : UIActionSheet = UIActionSheet(title: "Media message", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Send photo")
        sheet.showFromToolbar(self.inputToolbar)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return
        }
        
        switch (buttonIndex) {
            
        case 1:
            
            self.presentViewController(imagePicker!, animated: true, completion: nil)
            break
        case 2:
            
            let locationItem: JSQLocationMediaItem = JSQLocationMediaItem(location: self.locationManager.location)
            locationItem.setCoordinate(self.locationManager.location.coordinate)
            
            
            let locationMessage: JSQMessage = JSQMessage(senderId: "123", displayName: "123", media: locationItem)//(senderId: "123", senderDisplayName: "123", date: NSDate(), media: locationItem)
            self.messages.addObject(locationMessage)
            break
        case 3:
            let videoItem: JSQVideoMediaItem = JSQVideoMediaItem(fileURL: nil, isReadyToPlay: true)
            let videoMessage: JSQMessage = JSQMessage(senderId: "123", senderDisplayName: "123", date: NSDate(), media: videoItem)
            self.messages.addObject(videoMessage)
            break
        default:
            break
        }
        
        self.finishSendingMessageAnimated(true)
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
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let scaledImage = reduceImageSize(image)
        
        
        let photoItem: JSQPhotoMediaItem = JSQPhotoMediaItem(image: scaledImage)
        let photoMessage: JSQMessage = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photoItem)
        self.messages.addObject(photoMessage)
        self.finishSendingMessage()
        
        UIImageWriteToSavedPhotosAlbum(scaledImage, self, nil, nil)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        hud.labelText = "上傳中"
        
        hud.mode = MBProgressHUDModeAnnularDeterminate
        
        let service: StorageService = StorageService()
        
        service.uploadImage(scaledImage, hud: hud, completion:{(url) in
            
            let mlat =  self.locationManager.location.coordinate.latitude
            let mlong =  self.locationManager.location.coordinate.longitude
            
            //-----------Todo----------------////
            DataManager.PostRescueInfo(mlat, long: mlong, photourl: url)
            hud.hide(true)
        })
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!){
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item] as JSQMessage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var msg = messages[indexPath.item] as JSQMessage
        
        if(msg.senderId == self.senderId){
            return outgoingBubbleImageView
        }
        
        return incomingBubbleImageView
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item] as JSQMessage
        
        return NSAttributedString(string:message.senderDisplayName)
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item] as JSQMessage
        
        if (!message.isMediaMessage) {
            
            if message.senderId == self.senderId {
                
                cell.textView.textColor = UIColor.blackColor()
            }
            else {
                
                cell.textView.textColor = UIColor.whiteColor()
            }
            let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
            cell.textView.linkTextAttributes = attributes
        }
        
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item] as JSQMessage
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "HH:mm:ss"
        let messageDate = dateFormatter.stringFromDate(message.date)
        
        return NSAttributedString(string: messageDate)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item] as JSQMessage
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item > 0 {
            let perviousMessage = messages[indexPath.item - 1] as JSQMessage
            if perviousMessage.senderId == message.senderId{
                return nil
            }
        }
        return NSAttributedString(string:message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item] as JSQMessage
        
        if message.senderId == self.senderId{
            return CGFloat(0.0)
        }
        if indexPath.item > 0{
            let previousMessage = messages[indexPath.item - 1] as JSQMessage
            if previousMessage.senderId == message.senderId {
                return(0.0)
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


