//
//  SearchIndicator.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/27.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation
import UIKit

protocol SearchIndicatorDelegate{
    func didStartSearchIndicator()
    func didStopSearchIndicator()
}

class SearchIndicator: UIView {
    let searchTime = 30.0
    
    let circleOutsideRingLayer = CAShapeLayer()
    let circleInsideRingLayer = CAShapeLayer()
    let circleAnimationLineLayer = CAShapeLayer()
    
    let originFrame: CGRect?
    let recognizer: UITapGestureRecognizer?
    let label: UILabel?
    let titleLabel: UILabel?
    let imageView = UIImageView()
    
    let fullRotation = CGFloat(M_PI * 2)
    let duration = 0.6
    let delay = 0.0
    let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
    
    var delegate: SearchIndicatorDelegate?
    
    
    var isSearching = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.originFrame = frame

        createLayer()
        
        recognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        self.label = UILabel(frame: CGRectMake(-42, -160, 100, 100))
        self.label!.text = ""
        self.label!.font = self.label!.font.fontWithSize(40)
        
        self.titleLabel = UILabel(frame: CGRectMake(-90, -140, 200, 100))
        self.titleLabel!.text = "點選按鈕搜尋"
        self.titleLabel!.font = self.titleLabel!.font.fontWithSize(32)

        

        self.imageView = UIImageView(frame: CGRectMake(-40, -40, 80, 80))
        self.imageView.image = UIImage(named: "near-me")
        
        self.addSubview(self.imageView)
        
        self.addSubview(self.label!)
        self.addSubview(self.titleLabel!)
        
        self.addGestureRecognizer(recognizer!)
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        start()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start(){
        isSearching = true
        self.delegate?.didStartSearchIndicator()
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            
            
            UIView.animateKeyframesWithDuration(self.duration, delay: self.delay, options: self.options, animations: {
                // each keyframe needs to be added here
                // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                    // start at 0.00s (5s × 0)
                    // duration 1.67s (5s × 1/3)
                    // end at   1.67s (0.00s + 1.67s)
                    self.imageView.transform = CGAffineTransformMakeRotation(1/3 * self.fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                    self.imageView.transform = CGAffineTransformMakeRotation(2/3 * self.fullRotation)
                })
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                    self.imageView.transform = CGAffineTransformMakeRotation(3/3 * self.fullRotation)
                })
                
                }, completion: {finished in
                    
                    UIView.animateWithDuration(0.38, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.label!.text = ""
                        
                        self.transform = CGAffineTransformMakeScale(1, 1)
                        self.frame.origin.y = self.originFrame!.origin.y
                        self.frame.origin.x = self.originFrame!.origin.x
                        }, completion: { finised in
                            self.addGestureRecognizer(self.recognizer!)
                            self.circleAnimationLineLayer.opacity = 0
                            
                            self.titleLabel!.text = "點選按鈕搜尋"
                            self.delegate?.didStopSearchIndicator()
                            
                            self.isSearching = false
                    })
            })
            
           
        })
        
       

        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                // start at 0.00s (5s × 0)
                // duration 1.67s (5s × 1/3)
                // end at   1.67s (0.00s + 1.67s)
                self.imageView.transform = CGAffineTransformMakeRotation(1/3 * self.fullRotation)
            })
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                self.imageView.transform = CGAffineTransformMakeRotation(2/3 * self.fullRotation)
            })
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                self.imageView.transform = CGAffineTransformMakeRotation(3/3 * self.fullRotation)
            })
            
            }, completion: {finished in
                
                UIView.animateWithDuration(0.5, delay: 0.6, options: .CurveEaseOut, animations: {
                    let oldPosition = self.frame.origin.x
                    self.transform = CGAffineTransformMakeScale(0.6, 0.6)
                    let newPosition = self.frame.origin.x - oldPosition
                    self.frame.origin.y += 150
                    self.frame.origin.x -= newPosition
                    self.titleLabel?.text=""
                    println(self.frame.origin.x)
                    
                    }, completion: { finised in
                        self.label!.text = "搜尋"
                        self.circleAnimationLineLayer.opacity = 1
                })
        })
        
        self.removeGestureRecognizer(self.recognizer!)
        let strokEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokEndAnimation.fromValue = 0
        strokEndAnimation.toValue = 1.08
        strokEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        strokEndAnimation.beginTime = CACurrentMediaTime() + 1.8
        strokEndAnimation.duration = searchTime
        strokEndAnimation.removedOnCompletion = false
        
        circleAnimationLineLayer.addAnimation(strokEndAnimation, forKey: "strokeEnd")
        CATransaction.commit()
    
    }
    
    func createLayer(){
        
        let width = originFrame?.width
        
        var linePath = UIBezierPath(arcCenter:  CGPointMake(0, 0), radius: CGFloat(width!+1), startAngle: CGFloat(-0.5 * M_PI), endAngle: CGFloat(1.5 * M_PI), clockwise: true)
        
        var outLinePath = UIBezierPath(arcCenter:  CGPointMake(0, 0), radius: CGFloat(width!+6), startAngle: CGFloat(-0.5 * M_PI), endAngle: CGFloat(1.5 * M_PI), clockwise: true)
        
        
        var path = UIBezierPath(arcCenter:  CGPointMake(0, 0), radius: CGFloat(width!), startAngle: CGFloat(-0.5 * M_PI), endAngle: CGFloat(1.5 * M_PI), clockwise: true)
        
        
        circleOutsideRingLayer.path = outLinePath.CGPath
        circleOutsideRingLayer.strokeColor = UIColor(red: 252/255, green: 143/255, blue: 46/255, alpha: 1).CGColor
        circleOutsideRingLayer.lineWidth = 4
        circleOutsideRingLayer.fillColor = nil
        circleOutsideRingLayer.contentsScale = UIScreen.mainScreen().scale
        
        
        circleInsideRingLayer.path = path.CGPath
        circleInsideRingLayer.strokeColor = nil
        circleInsideRingLayer.lineWidth = 1.65
        circleInsideRingLayer.fillColor = UIColor(red: 252/255, green: 143/255, blue: 46/255, alpha: 1).CGColor
        circleInsideRingLayer.contentsScale = UIScreen.mainScreen().scale
        
        circleAnimationLineLayer.path = linePath.CGPath
        circleAnimationLineLayer.strokeColor = UIColor(red: 252/255, green: 143/255, blue: 46/255, alpha: 1).CGColor
        circleAnimationLineLayer.lineWidth = 6
        circleAnimationLineLayer.fillColor = nil
        circleAnimationLineLayer.contentsScale = UIScreen.mainScreen().scale
        
        circleAnimationLineLayer.opacity = 0
        
        self.layer.addSublayer(circleInsideRingLayer)
        
        self.layer.addSublayer(circleOutsideRingLayer)
        
        self.layer.addSublayer(circleAnimationLineLayer)
        
        
        
        
        
    }
    
}