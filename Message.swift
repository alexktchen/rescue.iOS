//
//  TLSPost.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/26.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class Message: NSObject, JSQMessageData {
    
    var mdate: NSDate = NSDate()
    var mid: String = ""
    var mimageUrl: String?
    var mlatitude: Double = 0.0
    var mlongitude: Double = 0.0
    var mreceived: Bool = false
    var mrecordeUrl: String = ""
    var msend: Bool = false
    var mtext: String = ""
    var msender: String?
    var mvideoUrl: String?
    
    
     override init() {
        
        super.init()
      //  self.mtext = text
       // self.msender = sender
       // self.mdate = sendDate
       // self.mimageUrl = imgUrl
        
    }
    
    
    func encodeWithCoder(aCoder: NSCoder!) {
        
        aCoder.encodeObject(self.mtext, forKey: "text")
        aCoder.encodeObject(self.msender, forKey: "sender")
        aCoder.encodeObject(self.mdate, forKey: "date")
        aCoder.encodeObject(self.mimageUrl, forKey: "imageUrl")
        
    }
    
    init(coder decoder: NSCoder!) {
        
        self.mtext = decoder.decodeObjectForKey("text") as String
        self.msender = decoder.decodeObjectForKey("sender") as? String
        self.mdate = decoder.decodeObjectForKey("date") as NSDate
        self.mimageUrl = decoder.decodeObjectForKey("imageUrl") as? String
        
    }
    
    
    
    func text() -> String! {
        return mtext;
    }
    
    func sender() -> String! {
        return msender;
    }
    
    func date() -> NSDate! {
        return mdate;
    }
    
    func getDateString()-> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // superset of OP's format
        let str = dateFormatter.stringFromDate(mdate)
        
        return str;
    }
    
    func imageUrl() -> String? {
        return mimageUrl;
    }
    
    
}

