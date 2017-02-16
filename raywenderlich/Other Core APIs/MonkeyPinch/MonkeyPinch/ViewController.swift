//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Abhijeet Mishra on 16/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var monkey: UIImageView!
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
   
    override func viewDidLoad() {
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(handleTap(sender:)))
        //resolving dependencies
        tapGestureRecognizer.require(toFail: monkeyPan)
        
        monkey.addGestureRecognizer(tapGestureRecognizer)
        
        let tickleGestureRecognizer = TickleGestureRecognizer.init(target: self, action:#selector(handleTickle(sender:)))
        monkey.addGestureRecognizer(tickleGestureRecognizer)
        
        super.viewDidLoad()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTickle(sender:TickleGestureRecognizer)  {
        let alertController = UIAlertController.init(title: "MonkeyPinch", message: "Monkey Tickled", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleTap(sender:UITapGestureRecognizer)  {
       let alertController = UIAlertController.init(title: "MonkeyPinch", message: "Monkey Tapped!", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    @IBAction func handleRotate(_ sender: UIRotationGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
    
        let translation = sender.translation(in: view)
        
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: view)
    
        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            let magnitude = sqrt(velocity.x*velocity.x + velocity.y*velocity.y)
            let scaleMultiplier = magnitude/200
            
            let scaleFactor = scaleMultiplier*0.1
            
           var finalPoint = CGPoint(x:min((sender.view?.center.x)! + scaleFactor*velocity.x, view.bounds.size.width), y:min((sender.view?.center.y)! + scaleFactor*velocity.y, view.bounds.size.height))
            
            finalPoint = CGPoint(x: max(0, finalPoint.x),y:max(0, finalPoint.y))
            
            UIView.animate(withDuration: TimeInterval(scaleFactor*2), animations: { 
                sender.view?.center = finalPoint
            })
        }
    }
}

