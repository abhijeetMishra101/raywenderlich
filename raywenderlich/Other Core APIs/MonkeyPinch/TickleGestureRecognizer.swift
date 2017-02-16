//
//  TickleGestureRecognizer.swift
//  MonkeyPinch
//
//  Created by Abhijeet Mishra on 16/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class TickleGestureRecognizer: UIGestureRecognizer {
    
    let requiredTickles = 2
    let distanceForTickleGesture:CGFloat = 25.0
    
    enum Direction:Int {
        case DirectionUnknown
        case DirectionLeft
        case DirectionRight
    }
    
    var tickleCount:Int = 0
    var tickleStartPoint:CGPoint = CGPoint.zero
    var lastTickleDirection:Direction = .DirectionUnknown
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if touches.first != nil {
            tickleStartPoint = touches.first!.location(in: view)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            let ticklePoint = touch.location(in: view)
            
            let varX = ticklePoint.x - tickleStartPoint.x
            
            var tickleDirection:Direction
            
            if varX < 0 {
                tickleDirection = .DirectionLeft
            }
            else {
                tickleDirection = .DirectionRight
            }
            
            if abs(varX) < distanceForTickleGesture {
                return
            }
            
            if lastTickleDirection == .DirectionUnknown || ((tickleDirection == .DirectionLeft && lastTickleDirection == .DirectionRight) || (tickleDirection == .DirectionRight && lastTickleDirection == .DirectionLeft)) {
                tickleCount += 1
                lastTickleDirection = tickleDirection
                tickleStartPoint = ticklePoint
                
                if state == .possible || tickleCount > requiredTickles {
                    state = .ended
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    override func reset()  {
        tickleCount = 0
        tickleStartPoint = CGPoint.zero
        lastTickleDirection = .DirectionUnknown
        if state == .possible {
            state = .failed
        }
    }
}
