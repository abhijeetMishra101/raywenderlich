//
//  SettingsTableViewController.swift
//  Pet Finder
//
//  Created by Essan Parto on 5/16/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
  @IBOutlet weak var themeSelector: UISegmentedControl!
  @IBOutlet weak var applyButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(SettingsTableViewController.dismiss as (SettingsTableViewController) -> () -> ()))
    
    themeSelector.selectedSegmentIndex = ThemeManager.currentTheme().rawValue
  }
  
  func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func applyTheme(_ sender: UIButton) {
    if let selectedTheme = Theme(rawValue: themeSelector.selectedSegmentIndex) {
        ThemeManager.applyTheme(theme: selectedTheme)
    }
    dismiss()
  }
}
