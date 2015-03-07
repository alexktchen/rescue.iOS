//
//  AvatarCell.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/25.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation

class AvatarView: UIView {
    
    var view: UIView!
    
    @IBOutlet weak var userNameLabel: UILabel!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(){
        self.view = loadViewFromNib()
      
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AvatarView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
       
        return view
    }
}