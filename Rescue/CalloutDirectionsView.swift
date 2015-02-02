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
  
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
 
   

    func instanceFromNib(btn:UIButton) -> UIView {
        var view = UINib(nibName: "CalloutDirectionsView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        view.frame = bounds
      //  view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
      //  self.addSubview(view)
        button = btn
        return view
    }
    
    
    func addTarget(target:AnyObject,action:Selector,events:UIControlEvents){

        button.addTarget(target, action: action, forControlEvents: events)
    }
}