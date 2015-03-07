//
//  Location.swift
//  Rescue
//
//  Created by Alex Chen on 2015/3/1.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation

class Location: NSObject {
    
    var lat: Double = Double()
    var long: Double = Double()
    var name: String = String()
    var tel: String = String()
    
    var type: Int = Int()
    
    init(name: String,tel: String, long: Double, lat: Double, type: Int){
        self.lat = lat
        self.long = long
        self.name = name
        self.tel = tel
        self.type = type
    }
    
}