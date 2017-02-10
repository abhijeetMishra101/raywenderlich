//
//  PushButtonView.swift
//  Flo
//
//  Created by Abhijeet Mishra on 08/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

@IBDesignable

class PushButtonView: UIButton {

    @IBInspectable var fillColor:UIColor = UIColor.green
    @IBInspectable var isAddButton:Bool = true
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath.init(ovalIn: rect)
        fillColor.setFill()
        path.fill()
        
        let plusHeight:CGFloat = 3.0
        let plusWidth:CGFloat = min(bounds.width, bounds.height) * 0.6
        
        //add the plus sign
        
        //create the path
        let plusPath =  UIBezierPath()
        
        plusPath.lineWidth = plusHeight
      
        //add the plus sign horizontal line
        plusPath.move(to: CGPoint(x:bounds.width/2 - plusWidth/2 + 0.5, y:bounds.height/2 + 0.5))
        plusPath.addLine(to: CGPoint(x: bounds.width/2 + plusWidth/2 + 0.5, y:bounds.height/2 + 0.5))
        if isAddButton {
            //add the plus sign vertical line
            plusPath.move(to: CGPoint(x:bounds.width/2 + 0.5, y:(bounds.height/2 - plusWidth/2 + 0.5)))
            plusPath.addLine(to: CGPoint(x:bounds.width/2 + 0.5, y:(bounds.height/2 + plusWidth/2 + 0.5)))
        }
      
        UIColor.white.setStroke()
        plusPath.stroke()
    }
}
