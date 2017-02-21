//
//  WorkoutsTableViewController.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import HealthKit

public enum DistanceUnit:Int {
  case miles=0, kilometers=1
}

open class WorkoutsTableViewController: UITableViewController {
  
  let kAddWorkoutReturnOKSegue = "addWorkoutOKSegue"
  let kAddWorkoutSegue  = "addWorkoutSegue"
  
  var distanceUnit = DistanceUnit.miles
  var healthManager:HealthManager?
  
  var workouts = [HKWorkout]()
  
  // MARK: - Formatters
  lazy var dateFormatter:DateFormatter = {
    
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    return formatter;
    
    }()
  
  let durationFormatter = DateComponentsFormatter()
  let energyFormatter = EnergyFormatter()
  let distanceFormatter = LengthFormatter()
  
  // MARK: - Class Implementation
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    self.clearsSelectionOnViewWillAppear = false
    
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    healthManager?.readRunningWorkOuts(completion: { (results) in
      print("Workouts read successfully")
    
      self.workouts = results as! [HKWorkout]
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    })
  }
  
  open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return workouts.count
  }
  
  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "workoutcellid", for: indexPath) as! UITableViewCell
    
    let workout = workouts[indexPath.row]
    let startDate = dateFormatter.string(from: workout.startDate)
    cell.textLabel?.text = startDate
    
    var detailText = "Duration: " + durationFormatter.string(from: workout.duration)!
    detailText += "Distance: "
    
    if distanceUnit == .kilometers {
      let distanceInKM = workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
      detailText += distanceFormatter.string(fromValue: distanceInKM!, unit: LengthFormatter.Unit.kilometer)
    }
    else {
      let distanceInMiles = workout.totalDistance?.doubleValue(for: HKUnit.mile())
      detailText += distanceFormatter.string(fromValue: distanceInMiles!, unit: LengthFormatter.Unit.mile)
    }
    
    let energyBurned = workout.totalEnergyBurned?.doubleValue(for: HKUnit.joule())
    detailText += "Energy: " + energyFormatter.string(fromJoules: energyBurned!)
    cell.detailTextLabel?.text = detailText
    
    return cell
  }
  
  open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if( segue.identifier == kAddWorkoutSegue )
    {
      
      if let addViewController:AddWorkoutTableViewController = segue.destination.inputViewController as? AddWorkoutTableViewController {
        addViewController.distanceUnit = distanceUnit
      }
    }
    
  }
  
  @IBAction func unitsChanged(_ sender:UISegmentedControl) {
    
    distanceUnit  = DistanceUnit(rawValue: sender.selectedSegmentIndex)!
    tableView.reloadData()
    
  }
  
  // MARK: - Segues
  @IBAction func unwindToSegue (_ segue : UIStoryboardSegue) {
    
    if( segue.identifier == kAddWorkoutReturnOKSegue )
    {
      if let addViewController:AddWorkoutTableViewController = segue.source as? AddWorkoutTableViewController {
     
        //set the unit type
        var hkUnit = HKUnit.meterUnit(with: .kilo)
        if distanceUnit  == .miles {
          hkUnit = HKUnit.mile()
        }
        //save the workout
        healthManager?.saveRunningWorkout(startDate: addViewController.startDate! as Date, endDate: addViewController.endDate! as Date, distance: addViewController.distance, distanceUnit: hkUnit, kiloCalories: addViewController.energyBurned!, completion: { (success) in
          if success {
            print("Workout saved")
          }
          else {
            
          }
        })
      }
    }
  }
}
