//
//  ViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SideBarDelegate {
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var navDelegate: MoveProtocolDelegate?
    
    var sideBar:SideBar = SideBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        reachability.startNotifier()
        
        sideBar = SideBar(sourceView: self.view, menuItems: ["test1","test2","test3"])
        sideBar.delegate = self
        
        
        // styling the navigation bar
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                println("Reachable via WiFi")
            } else {
                println("Reachable via Cellular")
            }
        } else {
            println("Not reachable")
        }
    }
    
    @IBAction func menuTap(sender: AnyObject) {
        
        if sideBar.isSideBarOpen{
            sideBar.showSideBar(false)
        }
        else{
            sideBar.showSideBar(true)
        }
        
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MapView") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
        
        sideBar.showSideBar(false)
    }
    
}

