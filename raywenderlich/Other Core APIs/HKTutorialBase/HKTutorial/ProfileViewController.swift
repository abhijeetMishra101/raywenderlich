//
//  ProfileViewController.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import HealthKit

class ProfileViewController: UITableViewController {
  
  let UpdateProfileInfoSection = 2
  let SaveBMISection = 3
  let kUnknownString   = "Unknown"
  
  @IBOutlet var ageLabel:UILabel!
  @IBOutlet var bloodTypeLabel:UILabel!
  @IBOutlet var biologicalSexLabel:UILabel!
  @IBOutlet var weightLabel:UILabel!
  @IBOutlet var heightLabel:UILabel!
  @IBOutlet var bmiLabel:UILabel!
  
  var healthManager:HealthManager?
  var bmi:Double?
  
  var height, weight:HKQuantitySample?
  
  func updateHealthInfo() {
    
    updateProfileInfo();
    updateWeight();
    updateHeight();
    
  }
  
  func updateProfileInfo()
  {
    //print("TODO: update profile Information")
  
    let profile = healthManager?.readProfile()
    ageLabel.text = profile?.age == nil ? kUnknownString : String(describing: profile!.age!)
    biologicalSexLabel.text = biologicalSexLiteral(profile?.biologicalSex?.biologicalSex)
    bloodTypeLabel.text = bloodTypeLiteral(profile?.bloodType?.bloodType)
  }
  
  
  func updateHeight()
  {
   
    let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)
    
    healthManager?.readMostRecentSample(sampleType: sampleType!, completion: { (mostRecentHeight) in
      var heightLocalizedString = self.kUnknownString
      self.height = mostRecentHeight as? HKQuantitySample
      
      if let meters = self.height?.quantity.doubleValue(for: HKUnit.meter()) {
        let heightFormatter = LengthFormatter()
        heightFormatter.isForPersonHeightUse = true
        heightLocalizedString = heightFormatter.string(fromMeters: meters)
      }
      
      DispatchQueue.main.async {
        self.heightLabel.text = heightLocalizedString
        self.updateBMI()
      }
    })
  }
  
  func updateWeight()
  {
    let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
    healthManager?.readMostRecentSample(sampleType: sampleType!, completion: { (mostRecentWeight) in
      var weightLocalizedString = self.kUnknownString
      
      //format the weight to display it on the screen
      self.weight = mostRecentWeight as? HKQuantitySample
      
      if let kilograms = self.weight?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)) {
        let weightFormatter = MassFormatter()
        weightFormatter.isForPersonMassUse = true
        weightLocalizedString = weightFormatter.string(fromKilograms: kilograms)
      }
      
      //update the UI in the main thread
      DispatchQueue.main.async {
        self.weightLabel.text = weightLocalizedString
        self.updateBMI()
      }
    })
  }
  
  func updateBMI()
  {
  
    if  weight != nil && height != nil {
      //1 get the weight and height values from the sample read from HealthKit
      let weightInKilograms = weight!.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
      let heightInMeters = height!.quantity.doubleValue(for: HKUnit.meter())
      
      bmi = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
    }
    
    var bmiString = kUnknownString
    if bmi != nil {
      bmiLabel.text = String.init(format: "%.02f", bmi!)
    }
  }
  
  func saveBMI()
  {
    if bmi != nil {
      healthManager?.saveBMISample(bmi: bmi!, date: Date.init())
    }
    else {
      print("There is no BMI data to save")
    }
  }
  // MARK: - utility methods
  func calculateBMIWithWeightInKilograms(_ weightInKilograms:Double, heightInMeters:Double) -> Double?
  {
    if heightInMeters == 0 {
      return nil;
    }
    return (weightInKilograms/(heightInMeters*heightInMeters));
  }
  
  
  func biologicalSexLiteral(_ biologicalSex:HKBiologicalSex?)->String
  {
    var biologicalSexText = kUnknownString;
    
    if  biologicalSex != nil {
      
      switch( biologicalSex! )
      {
      case .female:
        biologicalSexText = "Female"
      case .male:
        biologicalSexText = "Male"
      default:
        break;
      }
      
    }
    return biologicalSexText;
  }
  
  func bloodTypeLiteral(_ bloodType:HKBloodType?)->String
  {
    
    var bloodTypeText = kUnknownString;
    
    if bloodType != nil {
      
      switch( bloodType! ) {
      case .aPositive:
        bloodTypeText = "A+"
      case .aNegative:
        bloodTypeText = "A-"
      case .bPositive:
        bloodTypeText = "B+"
      case .bNegative:
        bloodTypeText = "B-"
      case .abPositive:
        bloodTypeText = "AB+"
      case .abNegative:
        bloodTypeText = "AB-"
      case .oPositive:
        bloodTypeText = "O+"
      case .oNegative:
        bloodTypeText = "O-"
      default:
        break;
      }
      
    }
    return bloodTypeText;
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath , animated: true)
    
    switch (indexPath.section, indexPath.row)
    {
    case (UpdateProfileInfoSection,0):
      updateHealthInfo()
    case (SaveBMISection,0):
      saveBMI()
    default:
      break;
    }
    
    
  }
  
}
