//
//  TLSPost.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/26.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class Message: NSObject, JSQMessageData {
    

    
    //發送時間
    var sendDateTime: NSDate = NSDate()
    //上傳時間
    var uploadDateTime: NSDate = NSDate()
    //接收時間
    var sreceivedDateTime: NSDate = NSDate()
    //訊息id(GUID)
    var id: String = ""
    //上傳照片 Url
    var imageUrl: String?
    //發送者 lat
    var latitude: Double = 0.0
    //發送者 long
    var longitude: Double = 0.0
    //是否被接收
    var received: Bool = false
    //錄音 url
    var recordeUrl: String = ""
    //是否發送
    var send: Bool = false
    //是否上傳
    var uploaded: Bool = false
    //訊息內容
    var text: String = ""
    //發送者
    var sender: String = ""
    //發送者id
    var msgSenderId: String = ""
    //接收者
    var receiver: String = ""
    //影片 url
    var videoUrl: String?
    //訊息轉發次數
    var transmitCount:Int = 0
    //上傳者
    var uploader: String = ""
    
     override init() {
        super.init()
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.text, forKey: "text")
        aCoder.encodeObject(self.sender, forKey: "sender")
        aCoder.encodeObject(self.sendDateTime, forKey: "sendDateTime")
        aCoder.encodeObject(self.imageUrl, forKey: "imageUrl")
        
    }
    
    init(coder decoder: NSCoder!) {
        
        self.text = decoder.decodeObjectForKey("text") as String
        self.sender = decoder.decodeObjectForKey("sender") as String!
        self.sendDateTime = decoder.decodeObjectForKey("sendDateTime") as NSDate
        self.imageUrl = decoder.decodeObjectForKey("imageUrl") as? String
        
    }
    
 

    func senderId() -> String! {
        return ""
    }
    
    func senderDisplayName() -> String! {
        return ""
    }
    func date() -> NSDate! {
        return NSDate()
    }
    func isMediaMessage() -> Bool {
        return false
    }
    func hash() -> UInt {
       return 0
    }
  
    
    func getDateString()-> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // superset of OP's format
        let str = dateFormatter.stringFromDate(sendDateTime)
        
        return str;
    }

}

