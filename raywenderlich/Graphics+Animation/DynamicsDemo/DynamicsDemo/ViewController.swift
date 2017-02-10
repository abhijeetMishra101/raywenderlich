//
//  ViewController.swift
//  DynamicsDemo
//
//  Created by Abhijeet Mishra on 08/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    
    var collision: UICollisionBehavior!
    var item: UIDynamicItemBehavior!
    
    var collisionCount = 0
    
    var isFirstContact = false
    
    var square: UIView!
    var snap: UISnapBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //adding the player view
        square = UIView(frame:CGRect(x:100, y:100, width:100, height:100))
        square.backgroundColor = UIColor.gray
        view.addSubview(square)
        
        //adding gravity
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items:[square])
        animator.addBehavior(gravity)
        
        //adding elasticity
        item = UIDynamicItemBehavior(items:[square])
        item.elasticity = 0.6
        animator.addBehavior(item)
        
        //adding the collision
        collision = UICollisionBehavior(items:[square])
        collision.collisionDelegate = self
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        //handling collisions
        let redRod = UIView(frame:CGRect(x:0, y:300, width:149, height:20))
        redRod.backgroundColor = UIColor.red
        view.addSubview(redRod)
        
        //adding the boundary
        collision.addBoundary(withIdentifier:"redRod" as NSCopying, for: UIBezierPath(rect:redRod.frame))
        
        collision.action = {
        print("\(NSStringFromCGAffineTransform(self.square.transform)) \(NSStringFromCGPoint(self.square.center))")
            
//            if self.collisionCount%3 == 0 {
//                let outline = UIView(frame:square.bounds)
//                outline.transform = square.transform
//                outline.center = square.center
//                outline.alpha = 0.5
//                outline.backgroundColor = UIColor.clear
//                outline.layer.borderWidth = 1.0
//                outline.layer.borderColor = square.layer.presentation()?.backgroundColor
//                self.view.addSubview(outline)
//            }
//            self.collisionCount += 1;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if snap != nil {
            animator.removeBehavior(snap)
        }
        
        let touch = touches.first! as UITouch
        snap = UISnapBehavior(item: square, snapTo: touch.location(in: view))
        animator.addBehavior(snap)
    }
}

extension ViewController: UICollisionBehaviorDelegate {
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        print("Collision occured for boundary identifier:\(identifier)")
        
        guard identifier != nil else {
            return
        }
        
            let collidingView = item as! UIView
            collidingView.backgroundColor = UIColor.gray
            
            if !isFirstContact {
                isFirstContact = true
                
                let square = UIView(frame: CGRect(x:200, y: 300, width:item.bounds.width, height:item.bounds.height))
                square.backgroundColor = UIColor.gray
                view.addSubview(square)
                
                collision.addItem(square)
                gravity.addItem(square)
                
                let attachment = UIAttachmentBehavior(item: item, attachedTo: square)
                animator.addBehavior(attachment)
            }
        
    }
}

