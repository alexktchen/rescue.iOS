//
//  SettingViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/1.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import CoreData

class SettingViewController : UITableViewController{
    
    @IBOutlet weak var nameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = "設定"

        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName"){
            self.nameLabel.text = name
        }
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(indexPath.section)
        print(indexPath.row)
        
        if(indexPath.section == 1){
            if(indexPath.row==0){
                
            }
        }
        else if(indexPath.section == 2){
            if(indexPath.row==0){
                
                let appDelegte = UIApplication.sharedApplication().delegate as AppDelegate
                let managedContext = appDelegte.managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Messages")
                
                
                var error: NSError?
                let fetchedResults = managedContext?.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                
                var msg: String?
                
                if let results = fetchedResults{
                    
                    for result in results{
                        managedContext?.deleteObject(result as NSManagedObject)
                    }
                    
                    managedContext?.save(&error)
                    
                    msg = "清除成功"
                    
                }
                else{
                    print(error)
                    msg = "清除失敗"
                }
                
                
                let alertController = UIAlertController(title: "刪除", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}