//
//  MessageSendView.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/16.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//


import UIKit

@IBDesignable class MessageSendView: UIView {
    
 
    var view: UIView!
    
    @IBOutlet weak var main: UIView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func setup(){
        view = loadViewFromNib()
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "SendMessageView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        return view
    }
 
}




