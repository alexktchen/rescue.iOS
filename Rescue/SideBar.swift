//
//  SideBar.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate{
    func sideBarDidSelectButtonAtIndex(index:Int)
    optional func sideBarWillColse()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let barWidth:CGFloat = 150.0
    let sideBarTableViewTopInsert:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SiderBarTableViewController = SiderBarTableViewController()
    let originView:UIView!
    
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    
    override init() {
        super.init()
    }
    
    init(sourceView:UIView, menuItems:Array<String>) {
        super.init()
        originView = sourceView
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecognizer)
    }
    
    
    func setupSideBar(){
        
        sideBarContainerView.frame = CGRectMake(-barWidth, originView.frame.origin.y
            , barWidth, originView.frame.height)
        
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInsert, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
    }
    
    func handleSwipe(reconginzer:UISwipeGestureRecognizer){
        if reconginzer.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
            delegate?.sideBarWillColse?()
        }
        else{
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
    }
    
    
    func showSideBar(isShow:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = isShow
        
        let gravityX:CGFloat = (isShow) ? 1:-1.5
        let magnitude:CGFloat = (isShow) ? 10:-10
        let boundaryX:CGFloat = (isShow) ? barWidth : -barWidth - 1
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        let collisiionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisiionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
          animator.addBehavior(collisiionBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    func siderBarControllerDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
        
    }
}
