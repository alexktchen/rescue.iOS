//
//  TLSPost.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/26.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class TLSPost: NSObject {
    
    var author: NSString = "";
    //var createdAt: NSDate = NSDate.date();
    var content:NSString = ""
    
    init(author:NSString, content:NSString) {
        super.init()
        //self.createdAt = NSDate.date()
        self.author = author
        self.content = content
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
       // aCoder.encodeObject(self.createdAt, forKey: "createdAt")
        aCoder.encodeObject(self.author, forKey: "author")
        aCoder.encodeObject(self.content, forKey: "content")
    }
    
    init(coder aDecoder: NSCoder!) {
       // self.createdAt = aDecoder.decodeObjectForKey("createdAt") as NSDate
        self.author = aDecoder.decodeObjectForKey("author") as NSString
        self.content = aDecoder.decodeObjectForKey("content") as NSString
    }
}

