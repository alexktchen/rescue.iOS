//
//  KTAnnotation.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit
import MapKit

class KTAnnotation : NSObject, MKAnnotation, Printable {
    
    var coordinate: CLLocationCoordinate2D
    var title: String = ""
    var subtitle: String = ""
    override var description: String {
        get {
            return "KTAnnotation"
        }
    }	
    
    init(location coord:CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
    
}