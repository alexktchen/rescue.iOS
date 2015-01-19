//
//  NavViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/18.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit
import QuartzCore


protocol MoveProtocolDelegate{
    
    func moveToRight()
    func movePanelToOriginalPosition()
}

protocol SlideMoveProtocolDelegate {
    func openCenterController(controller: UIViewController)
}

class NavViewController: UIViewController {
    
    let cornerRadius = CGFloat(4)
    var panelWidth = CGFloat(100)
    var posY = CGFloat(0)
    var perVelocity = CGPoint(x: 0, y: 0)
    
    var centerViewController:ViewController = ViewController()
    var recognizer = UIPanGestureRecognizer()
    lazy var leftPanelViewController = LeftViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panelWidth = self.view.bounds.width - 50
        //self.centerViewController.view.tag =
        self.centerViewController.view.bounds = self.view.bounds
        // self.centerViewController.navDelegate = self
        self.addChildViewController(self.centerViewController)
        self.centerViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(self.centerViewController.view)
        
        self.setupGestures()
    }
    
    func setupGestures() {
        self.recognizer = UIPanGestureRecognizer(target: self, action: "movePanel:")
        self.recognizer.minimumNumberOfTouches = 1
        self.recognizer.maximumNumberOfTouches = 1
        self.recognizer.delegate = self
        self.centerViewController.view.addGestureRecognizer(recognizer)
        
        
    }
    
    func movePanelLeft() {
        self.movePanelLeft(shouldExpand: true)
    }
    
    func moveToRight(){
         self.movePanelLeft(shouldExpand: true)
    }
    
    func movePanelLeft(#shouldExpand: Bool) {
        if shouldExpand {
            var frame = self.centerViewController.view.frame
            frame.origin.x = panelWidth
            if var frameNav = self.navigationController?.navigationBar.frame {
                self.posY = frameNav.origin.y
                frameNav.origin.x = panelWidth
                
                UIView.animateWithDuration(0.25, delay: Double(0), options: .BeginFromCurrentState, animations:{
                    self.centerViewController.view.frame = frame
                    self.navigationController?.navigationBar.frame = frameNav
                    
                    }, completion: {
                        finished in
                        if finished {
                            // self.menuState = SSlideMenuState.LeftOpened
                        }
                })
            }
        }else{
            // self.movePanelToOriginalPosition()
        }
        
        
    }
    
    func movePanelToOriginalPosition() {
    }
    
    func leftView() -> UIView {
        
        self.leftPanelViewController.view.tag = 1;
        self.leftPanelViewController.delegate = self
        
        self.addChildViewController(self.leftPanelViewController)
        self.leftPanelViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(self.leftPanelViewController.view)
        
        
        self.showCenterViewWithShadow(true, withOffset: 2)
        
        return self.leftPanelViewController.view
    }
    
    func showCenterViewWithShadow(value :Bool, withOffset offset:CGFloat) {
        if value {
            self.centerViewController.view.layer.cornerRadius = cornerRadius
            self.centerViewController.view.layer.shadowColor = UIColor.blackColor().CGColor
            self.centerViewController.view.layer.shadowOpacity = 1
            self.centerViewController.view.layer.shadowOffset = CGSizeMake(offset, offset)
        }
        else {
            self.centerViewController.view.layer.cornerRadius = 0
            self.centerViewController.view.layer.shadowOffset = CGSizeMake(offset, offset)
            self.centerViewController.view.layer.shadowOpacity = 0
        }
    }
    func addLeftToView() {
        let childView = self.leftView()
        self.view.sendSubviewToBack(childView)
        // self.panningState = SPaningState.Right
    }
}

extension NavViewController:SlideMoveProtocolDelegate{
    
    func openCenterController(controller:UIViewController){
    }
}

extension NavViewController:MoveProtocolDelegate{
}



extension NavViewController:UIGestureRecognizerDelegate{
    
    func movePanel(tap:UIPanGestureRecognizer){
        
        let gestureIsDragingFromLeftToRight = (tap.velocityInView(view).x > 0)
        
        switch tap.state{
        case .Began:
            self.addLeftToView()
        case .Ended,.Cancelled:
            let hasMovedGreaterThanHalfway = tap.view!.center.x > view.bounds.size.width
            self.movePanelLeft(shouldExpand: hasMovedGreaterThanHalfway)
        case .Changed:
            tap.view!.center.x = tap.view!.center.x + tap.translationInView(view).x
            tap.setTranslation(CGPointZero, inView: view)
            self.navigationController!.navigationBar.center.x = tap.view!.center.x + tap.translationInView(view).x
        default:
            println("\(tap.state)")
        }
        
    }
}