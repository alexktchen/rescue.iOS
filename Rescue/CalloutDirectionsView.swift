//
//  CalloutDirectionsView.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/19.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

@IBDesignable
class CalloutDirectionsView: UIView{
    
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
   
    
    func instanceFromNib() -> UIView {
        var view = UINib(nibName: "CalloutDirectionsView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
      //  label.text = "123"
        return view
    }
    
    
    func addTarget(target:AnyObject,action:Selector,events:UIControlEvents){
        
         self.button.addTarget(target, action: action, forControlEvents: events)
    }
}