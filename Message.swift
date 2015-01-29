//
//  Message.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/25.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    var userName_:String?
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    
    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, imageUrl: nil)
    }
    
    init(text: String?, sender: String?, imageUrl: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func getDateString()-> String! {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // superset of OP's format
        let str = dateFormatter.stringFromDate(date_)
        
        return str;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
}