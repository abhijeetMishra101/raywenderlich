//
//  AddWorkoutTableViewController.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit

class AddWorkoutTableViewController: UITableViewController {
  
  
  
  @IBOutlet var dateCell:DatePickerCell!
  @IBOutlet var startTimeCell:DatePickerCell!
  
  @IBOutlet var durationTimeCell:NumberCell!
  @IBOutlet var caloriesCell:NumberCell!
  @IBOutlet var distanceCell:NumberCell!
  
  
  let kSecondsInMinute=60.0
  let kDefaultWorkoutDuration:TimeInterval=(1.0*60.0*60.0) // One hour by default
  let lengthFormatter = LengthFormatter()
  var distanceUnit = DistanceUnit.miles
  
  func datetimeWithDate(date:NSDate , time:NSDate) -> NSDate? {
    
    let currentCalendar = NSCalendar.current
    let dateComponents = currentCalendar.dateComponents([.day, .month], from: date as Date)
    let hourComponents = currentCalendar.dateComponents([.hour, .minute], from: time as Date)
    
   let dateWithTime = currentCalendar.date(byAdding: hourComponents, to: currentCalendar.date(from: dateComponents)!)
    
   // let dateWithTime = currentCalendar.addingComponents(hourComponents, toDate:currentCalendar.dateFromComponents(dateComponents)!, options:NSCalendar.Options(0))
    
    return dateWithTime as NSDate?;
    
  }
  
  
  var startDate:NSDate? {
    get {
      
      return datetimeWithDate(date: dateCell.date as NSDate, time: startTimeCell.date as NSDate )
    }
  }
  
  var endDate:NSDate? {
    get {
      let endDate = startDate?.addingTimeInterval(durationInMinutes*kSecondsInMinute)
      return endDate
    }
  }
  
  var distance:Double {
    get {
      return distanceCell.doubleValue
    }
  }
  
  
  var durationInMinutes:Double {
    get {
      return durationTimeCell.doubleValue
    }
  }
  
  var energyBurned:Double? {
    return caloriesCell.doubleValue
    
  }
  
  func updateOKButtonStatus() {
    
    self.navigationItem.rightBarButtonItem?.isEnabled = ( distanceCell.doubleValue > 0 && caloriesCell.doubleValue > 0 && distanceCell.doubleValue > 0);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateCell.inputMode = .date
    startTimeCell.inputMode = .time
    
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let endDate = NSDate()
    let startDate = endDate.addingTimeInterval(-kDefaultWorkoutDuration)
    
    dateCell.date = startDate as Date;
    startTimeCell.date = startDate as Date
    
    let formatter = LengthFormatter()
    formatter.unitStyle = .long
    let unit = distanceUnit == DistanceUnit.kilometers ? LengthFormatter.Unit.kilometer : LengthFormatter.Unit.mile
    let unitString = formatter.unitString(fromValue: 2.0, unit: unit)
    distanceCell.textLabel?.text = "Distance (" + unitString.capitalized + ")"
    self.navigationItem.rightBarButtonItem?.isEnabled  = false
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
  }
  
  @IBAction func textFieldValueChanged(sender:AnyObject ) {
    updateOKButtonStatus()
  }
  
  
  
}

