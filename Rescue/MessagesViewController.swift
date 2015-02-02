//
//  MessagesViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/25.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessagesViewController: JSQMessagesViewController {
    
    var messages = [Message]()
    
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    var session: SessionService?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
               
        session = SessionService(name: "My Name")
        
        session?.onReceive {
            (serializedPost:NSData) -> Void in
            var post = NSKeyedUnarchiver.unarchiveObjectWithData(serializedPost) as TLSPost
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
        
        sender = (sender != nil) ? sender : "Alex"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("notificationWasReceived:"), name: "postReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ChangesStatus:"), name: "ChangesStatusReceived", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("StatusBrowsing:"), name: "BrowsingReceived", object: nil)
        
        
        LoadMessage()
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
        }
    }
    
    func notificationWasReceived(notification: NSNotification) {
        
        var post = notification.object as TLSPost
        println(post.content)
        
        receiveMessage(post.content,sender:"test")
        
    }
    
    @IBAction func search(sender: AnyObject) {
        
    }
    
    func receiveMessage(text: String!, sender: String!){
        
        let message = Message(text: text, sender: sender)
        
        messages.append(message)
        
        delay(0.1) {
            self.finishReceivingMessage()
            self.scrollToBottomAnimated(true)
        }
        
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = text
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendMessage(text: String!, sender: String!) {
        
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        var post:TLSPost = TLSPost(author: "Matt", content: text)
        
        self.session?.send(post)
        
        let message = Message(text: text, sender: sender)
        self.messages.append(message)
        SaveMessage(message)

        finishReceivingMessage()
        scrollToBottomAnimated(true)
    }
    
    func SaveMessage(sendMsg : Message){
        
        let appDelegte = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegte.managedObjectContext
        
        let entiy = NSEntityDescription.entityForName("Messages", inManagedObjectContext: managedContext!)
        
        let object = NSManagedObject(entity: entiy!, insertIntoManagedObjectContext: managedContext)
        object.setValue(sendMsg.text_, forKey: "text")
        
        var error : NSError?
        
        if(managedContext?.save(&error) == nil){
            print(error)
        }
        
        message.append(object)
    }
    
    func LoadMessage(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Messages")
        
        var error: NSError?
        let fetchedResults = managedContext?.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults{
            
            for result in results{
                var msg: Message = Message(text: result.valueForKey("text") as? String, sender: sender)
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
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    var message = [NSManagedObject]()
    
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
        
        if message.sender() == sender{
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
        
        
        var label : UILabel = UILabel(frame: CGRectMake(0, 0, 50, 50))
        label.text="附近"
        
        label.font = UIFont(name: label.font.fontName, size: 9);
        label.textColor = UIColor.lightGrayColor();
        label.textRectForBounds(CGRectMake(-100, 0, 50, 50), limitedToNumberOfLines: 1);
        label.textAlignment = NSTextAlignment.Right;
        
        if message.sender() == sender {
            // cell.addSubview(label)
            
            // cell.subView.addSubview(label)
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
        if message.sender() == sender {
            return nil
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.sender() == sender {
            return CGFloat(0.0)
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0)
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
}


