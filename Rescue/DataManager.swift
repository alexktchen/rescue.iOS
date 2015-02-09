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
    
    //取得救難點
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
    
    //上傳求救訊號
    class func PostRescueInfo(data: NSObject) {
   
        let json:JSON =  ["id":"123", "xAddr":"11","yAddr":"11","rescueTime":"\(NSDate())","photoUrl":"","videoUrl":""]
    
        request(.POST, baseUrl + "api/rescueInfo", parameters: json.dictionaryObject, encoding: ParameterEncoding.JSON).responseJSON {
            (request, response, JSON, error) in
          //  println("request: \(request)")
          //  println("response: \(response)")
            println("JSON: \(JSON)")
            println("error: \(error)")
            
        }
    }
}