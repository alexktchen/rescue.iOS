//
//  StorageService.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/8.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit


class StorageService{
    
    var tableBlobBlobs: MSTable?
    
    var tableContainers: MSTable?
    
    init(){
        
        
        let client = MSClient(applicationURLString: "https://recuse-mobile-service.azure-mobile.net/", withApplicationKey: "oTghGlBNZdBTAqCUbrBfLIKrEnXHXJ26")
        
        self.tableBlobBlobs = client.getTable("BlobBlobs")
        
        self.tableContainers = client.getTable("BlobContainers")
        
        // loadData()
        
        //loadContainer()
        
        //uploadImage()
    }
    
    func containerExistAndCreate(userId: String, completion: (isExist: Bool)-> Void){
        
        let containerName = "container=\(userId)"

        
        self.tableContainers?.readWithQueryString(containerName, completion: {(results:[AnyObject]!, totalCount: Int!, error: NSError!) -> Void in
            
            if(totalCount == -1){
                
                completion(isExist: false)
            }
            else{
                completion(isExist: true)
            }

        })

    }
    
    
    func insertContainers(userId: String, completion: (name: String)-> Void){
        
        let item: NSDictionary = ["containerName":"\(userId)"]
        let params: NSDictionary = ["isPublic": "\(NSNumber(bool: true))"]
        
        self.tableContainers?.insert(item, parameters: params, completion: {
            (results:[NSObject : AnyObject]!, error: NSError!) -> Void in
            var json = JSON(results)
            println(json)
        })
    }
    
    func uploadImage(image:UIImage, hud: MBProgressHUD , completion: (url: String) -> Void){
        
        let data: NSData = UIImagePNGRepresentation(image)
        let item: NSDictionary = NSDictionary()

     
        let dateFormatter = NSDateFormatter()
   
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        
        dateFormatter.dateFormat = "yyyyMMddhhmmsss"
        let fileName = dateFormatter.stringFromDate(NSDate())
        
        let params: NSDictionary = ["containerName":"qqq","blobName":"\(fileName)"]
        
        self.tableBlobBlobs?.insert(item, parameters: params, completion: { (results:[NSObject : AnyObject]!, error: NSError!) -> Void in
            
            if(error == nil){
                
                var json = JSON(results)
                
                let sasUrl = json["sasUrl"].string
               
                let request = NSMutableURLRequest(URL: NSURL(string: sasUrl!)!)
                
                request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                request.HTTPMethod = "PUT"
                upload(request, data).progress(closure: {
                    (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                    println(totalBytesWritten)
                    hud.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                    
                }).responseJSON { (request, response, json, error) in
                    
                    if(error == nil){

                        let strUrl = "http://recusemobilestorage.blob.core.windows.net/qqq/" + fileName
                        
                        completion(url: strUrl)
                        println(request)
                        
                        println(json)
                    }
                    else{
                        println(error)
                    }
                    
                    completion(url: "")
                }
            }
            else{
                println(error)
            }
            
        })
    }
    
}
