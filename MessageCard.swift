//
//  MessageCard.swift
//  Rescue
//
//  Created by Alex Chen on 2015/3/1.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation

enum MessageType {
    case Photo
    case Text
}

class MessageCard: NSObject {
    
    var image: UIImage = UIImage()
    
    var sendDateTime: NSDate = NSDate()
    
    var imageUrl: String?
    
    var latitude: Double = 0.0
    
    var longitude: Double = 0.0
    
    var text: String = ""
    
    var type: Int = 0
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.text, forKey: "text")
        aCoder.encodeObject(self.latitude, forKey: "latitude")
        aCoder.encodeObject(self.longitude, forKey: "longitude")
        aCoder.encodeObject(self.image, forKey: "image")
        
        aCoder.encodeObject(self.sendDateTime, forKey: "sendDateTime")
        aCoder.encodeObject(self.imageUrl, forKey: "imageUrl")
        aCoder.encodeObject(self.type, forKey: "type")
        
        // aCoder.encodeObject(self.type, forKey: "type")
    }
    
    init(coder decoder: NSCoder!) {
        
        self.text = decoder.decodeObjectForKey("text") as String
        
        self.sendDateTime = decoder.decodeObjectForKey("sendDateTime") as NSDate
        self.imageUrl = decoder.decodeObjectForKey("imageUrl") as? String
        
        self.latitude = decoder.decodeObjectForKey("latitude") as Double
        self.longitude = decoder.decodeObjectForKey("longitude") as Double
        
        self.image = decoder.decodeObjectForKey("image") as UIImage
        
        self.type = decoder.decodeObjectForKey("type") as Int
    }
    
    
    init(image: UIImage,sendDateTime: NSDate, imageUrl: String, latitude: Double,longitude: Double,text: String){
        
        self.image = image
        self.sendDateTime = sendDateTime
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.longitude = longitude
        self.text = text
    }
    
    init(latitude: Double,longitude: Double,text: String){
        self.type = 1
        self.latitude = latitude
        self.longitude = longitude
        self.text = text
    }
    
    init(image: UIImage,latitude: Double,longitude: Double){
        self.type = 2
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}