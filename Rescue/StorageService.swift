//
//  StorageService.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/8.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit

class StorageService {
    /*
    var tableBlobBlobs: MSTable?
    
    var tableContainers: MSTable?
    
    init(){
        
        
        let client = MSClient(applicationURLString: "https://recuse-mobile-service.azure-mobile.net/", withApplicationKey: "oTghGlBNZdBTAqCUbrBfLIKrEnXHXJ26")
        
        self.tableBlobBlobs = client.getTable("BlobBlobs")
        
        self.tableContainers = client.getTable("BlobContainers")
        
        // loadData()
        
        //loadContainer()
        
        uploadImage()
    }
    
    func loadData() {
        
        self.tableContainers!.readWithCompletion({
            (results: [AnyObject]!, totalCount: Int!, error: NSError!) -> Void in
            
            if (error != nil){
                println(error)
            }
            
            
            var json = JSON(results!)
            
            for (key: String, subJson: JSON) in json {
                
                println(subJson["name"].string)
                
                let name = "container=" + subJson["name"].string!
                
                
                self.tableBlobBlobs!.readWithCompletion({
                    (results: [AnyObject]!, totalCount: Int!, error: NSError!) -> Void in
                    
                    println(results)
                    
                })
                
            }
        })
    }
    
    func loadContainer(){
        
        let name = "container=qqq"
        
        self.tableBlobBlobs?.readWithQueryString(name, completion: ({
            (results: [AnyObject]!, totalCount: Int!, error: NSError!) -> Void in
            
            println(results)
        }))
    }
    
    func uploadImage(){

        let myImage = UIImage(named:"Image-1")
        
        let data: NSData = UIImagePNGRepresentation(myImage)
        
        let item: NSDictionary = NSDictionary()
        let params: NSDictionary = ["containerName":"qqq","blobName":"6666666"]
        
        
        self.tableBlobBlobs?.insert(item, parameters: params, completion: { (results:[NSObject : AnyObject]!, error: NSError!) -> Void in
            
          
            if(error == nil){
                var json = JSON(results)
                println(json)
                
                let sasUrl = json["sasUrl"].string
                
                let request = NSMutableURLRequest(URL: NSURL(string: sasUrl!)!)
                
                request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                request.HTTPMethod = "PUT"
                
                upload(request, data).progress(closure: {
                    (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                    println(totalBytesWritten)
                }).responseJSON { (request, response, JSON, error) in
                    println(JSON)
                }

            }
            else{
                println(error)
            }
            
        })
        
        
        
        
    }
*/
}
