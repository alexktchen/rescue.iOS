//
//  DataManage.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/4.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation



let baseUrl = "http://rescueapiservice.azurewebsites.net/"


public class DataManager {
    
    
    class func getHelpInfos(success : ((lat: Double!,long:Double,name: String,tel: String) -> Void)) {
        
        request(.GET, baseUrl + "api/helpinfo", parameters: nil).responseJSON { (req, res, json, error) in
            
            if(error == nil) {
                
                var json = JSON(json!)
                
                for (key: String, subJson: JSON) in json {
                    
                    success(
                        lat: subJson["yAddr"].double,
                        long: subJson["xAddr"].double!,
                        name: subJson["name"].string!,
                        tel: subJson["tel"].string!
                    )
                }
            }
            else {
                
                NSLog("Error: \(error)")
                println(req)
                println(res)
            }
        }
    }
    
    
    class func PostRescueInfo(data: NSData) {
        
        var error:NSError? = nil

        let parameter = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: &error)
        
        if(error==nil){
            request(.POST, "http://httpbin.org/post", parameters: parameter.dictionaryObject)
        }
        else{
            
        }
    }

}