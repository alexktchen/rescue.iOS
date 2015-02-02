//
//  CollectionViewCell.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/28.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var textLabel: UILabel!
    
    let label: UILabel!
    
    let selectionView: UIView!
    var maskLayer: CAShapeLayer!
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        isSetTitle = false
        selectionView = UIView(frame: self.bounds)
        selectionView.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        selectionView.alpha = 0
        selectionView.backgroundColor = UIColor.blueColor()
        contentView.addSubview(selectionView)
        
        
        maskLayer = CAShapeLayer()
        maskLayer.strokeColor = UIColor.redColor().CGColor
        maskLayer.fillColor = UIColor.redColor().CGColor
        maskLayer.frame = CGRect(x: 2, y: 2, width: 118, height: 118)
        let pathRef = CGPathCreateWithEllipseInRect(maskLayer.frame, nil)
        maskLayer.path = pathRef
        //maskLayer.frame = self.bounds
        self.layer.mask = maskLayer
        self.layer.masksToBounds = true
        
        let textFrame = CGRect(x: 20, y: 12, width: frame.size.width, height: frame.size.height/3)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize())
        textLabel.textAlignment = .Left
        textLabel.textColor = UIColor.whiteColor()
        
        contentView.addSubview(textLabel)
    }
    
    
    
    func setTitle(title: String){
        
        textLabel.text = title
    }
    
    
    
    var isSetTitle: Bool = false {
        willSet(newTotalSteps) {
            println("About to set totalSteps to \(newTotalSteps)")
        }
        didSet {
            
        }
    }
    
    
    override var tintColor: UIColor! {
        didSet {
            self.selectionView.backgroundColor = tintColor
        }
    }
    
    override var highlighted: Bool {
        didSet {
            
            if (highlighted){
                
                UIView.animateWithDuration(Double(0.1),
                    animations: {
                        self.transform = CGAffineTransformMakeScale(0.9, 0.9)
                        self.selectionView.alpha = 1;
                    },nil)
                
                
            }
            else{
                
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    
                    self.transform = CGAffineTransformIdentity
                    self.selectionView.alpha = 1
                    
                    }, nil)
            }
            
        }
    }
    
    
}

