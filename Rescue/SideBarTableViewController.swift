//
//  SideBarTableViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

protocol SideBarTableViewControllerDelegate{
    func siderBarControllerDidSelectRow(indexPath:NSIndexPath)
}

class SiderBarTableViewController:UITableViewController{
    
    var delegate:SideBarTableViewControllerDelegate?
    var tableData:Array<String> = []
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel.textColor = UIColor.darkTextColor()
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            
            cell!.textLabel.text = tableData[indexPath.row]
            
            cell!.selectedBackgroundView = selectedView
        }
        
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.siderBarControllerDidSelectRow(indexPath)
    }
    
    
}
