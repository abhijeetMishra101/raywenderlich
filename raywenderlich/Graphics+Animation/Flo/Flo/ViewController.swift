//
//  ViewController.swift
//  Flo
//
//  Created by Abhijeet Mishra on 08/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var averageWaterDrunk: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var glassCounter = 0
    
    var isGraphViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
  
    @IBAction func containerViewTapped(_ sender: UITapGestureRecognizer) {
    
        if isGraphViewShowing {
            //hide graph view
            UIView.transition(from: graphView, to: counterView, duration: 1.0, options:[UIViewAnimationOptions.transitionFlipFromLeft,UIViewAnimationOptions.showHideTransitionViews], completion: nil)
        }
        else {
            //show graph view
             UIView.transition(from: counterView, to: graphView, duration: 1.0, options:[UIViewAnimationOptions.transitionFlipFromRight,UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            setupGraphDisplay()
        }
        isGraphViewShowing = !isGraphViewShowing
    }
    
    @IBAction func pushButtonTapped(_ sender: PushButtonView) {
        if sender.isAddButton && glassCounter < 8 {
            glassCounter += 1
        }
        else if !sender.isAddButton && glassCounter > 0 {
            glassCounter -= 1
        }
        counterLabel.text = String(glassCounter)
        counterView.counter = glassCounter
        counterView.setNeedsDisplay()
    }
    
    func setupGraphDisplay() {
        
        let noOfDays:Int = 7
        
        graphView.graphPoints[graphView.graphPoints.count - 1] = counterView.counter
        
        graphView.setNeedsDisplay()
        
        maxLabel.text = "\(graphView.graphPoints.max()!)"
        
        let average = graphView.graphPoints.reduce(0, +)
        / graphView.graphPoints.count
        averageWaterDrunk.text = "\(average)"
        
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let componentOptions: NSCalendar.Unit = NSCalendar.Unit.weekday
        
        
        let components = calendar.dateComponents(in: NSTimeZone.default, from: Date.init())
        var weekday = components.weekday!
        
        let days = ["S", "S", "M", "T", "W", "T", "F"]
        
        for i in (1...days.count).reversed() {
            if let labelView = graphView.viewWithTag(i) as? UILabel {
                if weekday == 7 {
                    weekday = 0
                }
                labelView.text = days[weekday]
                weekday -= 1
                if weekday < 0 {
                    weekday = days.count - 1
                }
            }
        }
    }
}

