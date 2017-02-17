//
//  TodayViewController.swift
//  TodayExampleWidget
//
//  Created by Abhijeet Mishra on 17/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode==NCWidgetDisplayMode.compact {
            self.preferredContentSize = CGSize(width:0, height:200)
        }
        else {
             self.preferredContentSize = maxSize
        }
    }
    
    @IBAction func expandButtonPressed(_ sender: UIButton) {
        if sender.currentTitle == "✛" {
            //expand the widget
            self.extensionContext?.widgetMaximumSize(for: NCWidgetDisplayMode.expanded)
            //self.containerViewHeight.constant = 320
            UIView.animate(withDuration: 1, animations: { 
            }, completion: { (completed) in
                sender.setTitle("✕", for: UIControlState.normal)
                self.preferredContentSize = CGSize(width:0 , height:200)
            })
        }
        else {
            //contract the widget
            UIView.animate(withDuration: 1, animations: {
                self.extensionContext?.widgetMaximumSize(for: NCWidgetDisplayMode.compact)
                // self.containerViewHeight.constant = 110
            }, completion: { (completed) in
                 sender.setTitle("✛", for: UIControlState.normal)
                 self.preferredContentSize = CGSize(width:0 , height:32)
            })
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
