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
    class func getHelpInfos(success : ((locations: NSMutableArray!) -> Void)) {
        
        request(.GET, baseUrl + "api/helpinfo", parameters: nil).responseJSON { (req, res, json, error) in
            
            if(error == nil) {
                
                var json = JSON(json!)
                let locations :NSMutableArray = NSMutableArray()

                for (key: String, subJson: JSON) in json {
                    
                    let location: Location = Location(name: subJson["name"].string!,tel: subJson["tel"].string!, long: subJson["yAddr"].double!, lat: subJson["xAddr"].double!, type: 0)
                   
                    locations.addObject(location)
                }

                success(
                    locations: locations
                )

            }
            else {
                
                NSLog("Error: \(error)")
                println(req)
                println(res)
            }
        }
    }
    
    class func getRescueInfo(success : ((locations: NSMutableArray!) -> Void)) {
        
        request(.GET, baseUrl + "api/rescueInfo", parameters: nil).responseJSON { (req, res, json, error) in
            
            if(error == nil) {
                
                var json = JSON(json!)
                
                let locations :NSMutableArray = NSMutableArray()
                
                
                for (key: String, subJson: JSON) in json {
                    
                    let location: Location = Location(name: "SOS",tel: subJson["photoUrl"].string!, long: subJson["yAddr"].double!, lat: subJson["xAddr"].double!, type: 1)

                    locations.addObject(location)
                }
                
                success(
                    locations: locations
                )
                
            }
            else {
                
                NSLog("Error: \(error)")
                println(req)
                println(res)
            }
        }
    }
    
    //上傳求救訊號
    class func PostRescueInfo(lat: Double,long: Double, photourl: String) {
   
        var uuid = NSUUID().UUIDString
        
        let json:JSON =  ["id":"\(uuid)", "xAddr":"\(lat)","yAddr":"\(long)","rescueTime":"\(NSDate())","photoUrl":"\(photourl)","videoUrl":""]
    
        request(.POST, baseUrl + "api/rescueInfo", parameters: json.dictionaryObject, encoding: ParameterEncoding.JSON).responseJSON {
            (request, response, JSON, error) in
          //  println("request: \(request)")
          //  println("response: \(response)")
            println("JSON: \(JSON)")
            println("error: \(error)")
            
        }
    }
}