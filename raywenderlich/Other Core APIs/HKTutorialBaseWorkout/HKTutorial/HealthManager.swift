//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {

  let healthKitStore:HKHealthStore = HKHealthStore()
  
  func authorizeHealthKit(completion: ((_ success:Bool) -> Void)!) {
    
    // Set the types you want to read from HK Store
 let healthKitTypesToRead = Set.init(arrayLiteral: HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!, HKObjectType.workoutType())
    
    
    //set the types you want to write to the HK Store
    let healthKitTypesToWrite = Set.init(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!)
    
    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
     // let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
        completion(false)
      return;
    }
    
    // 4.  Request HealthKit authorization
    healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
      
        completion(success)
    }
  }
  
  func readProfile () -> (age: Int? , biologicalSex:HKBiologicalSexObject?, bloodType:HKBloodTypeObject?) {
    var age: Int?
    
    do {
      //Request birthday and calculate age
       let birthDate = try healthKitStore.dateOfBirth()
      
      let todayDate = NSDate()
      let calendar = NSCalendar.current
      
      let differenceComponents = calendar.dateComponents([.year], from: birthDate, to: todayDate as Date)
      age = differenceComponents.year
    } catch  {
      
    }
    
    //read the sex info
    var biologicalSex:HKBiologicalSexObject?
    
    do {
     biologicalSex = try healthKitStore.biologicalSex()
      
    } catch  {
      
    }
    
    //read the blood type
    var bloodType:HKBloodTypeObject?
    do {
      bloodType = try healthKitStore.bloodType()
    } catch  {
      
    }
    return (age, biologicalSex, bloodType)
  }
  
  func readMostRecentSample (sampleType:HKSampleType , completion: ((HKSample?) -> Void)!) {
    
    //Build the predicate
    let past = Date.distantPast
    let now = Date()
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end: now, options: HKQueryOptions(rawValue:0))
    
    let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
    let limit = 1
    
    let sampleQuery = HKSampleQuery.init(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) -> Void in
      if let _ = error {
        completion(nil)
        return;
      }
      // get the first sample
        let mostRecentSample = results?.first as? HKQuantitySample
      
      //execute the completion closure
      completion(mostRecentSample)
    }
    //execute the query
    self.healthKitStore.execute(sampleQuery)
  }
  
  func saveBMISample (bmi: Double, date: Date) {
    
    //Create a BMI sample
    let bmiType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)
    let bmiQuantity = HKQuantity.init(unit: HKUnit.count(), doubleValue: bmi)
    let bmiSample = HKQuantitySample.init(type: bmiType!, quantity: bmiQuantity, start: date, end: date)
    
    //save the sample in the store
    healthKitStore.save(bmiSample) { (success, error) in
      if error != nil {
        print("Error saving sample")
      }
      else {
        print("BMI saved successfully")
      }
    }
  }
  
  func saveRunningWorkout (startDate:Date, endDate:Date, distance:Double, distanceUnit:HKUnit, kiloCalories:Double,completion:((Bool) -> Void)!) {
    
    // Create quanities for the distance and energy burned
    let distanceQuantity = HKQuantity.init(unit: distanceUnit, doubleValue: distance)
    let caloriesQuantity = HKQuantity.init(unit: HKUnit.kilocalorie(), doubleValue: kiloCalories)
    
    //Save Running Workout
   let workout = HKWorkout.init(activityType: HKWorkoutActivityType.running, start: startDate, end: endDate, duration: abs(endDate.timeIntervalSince(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: distanceQuantity, metadata: nil)
    healthKitStore.save(workout) { (success, error) in
      if error != nil {
        //completion(success)
        
        //if success then save the associated samples so that they appear in the Health Store
        let distanceSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!, quantity: distanceQuantity, start: startDate, end: endDate)
        let caloriesSample = HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!, quantity: caloriesQuantity, start: startDate, end: endDate)
        self.healthKitStore.add([distanceSample, caloriesSample], to: workout, completion: { (success, error) in
          completion(success)
        })
      }
      else {
        completion(false)
      }
    }
  }
  
  func readRunningWorkOuts(completion:@escaping ([AnyObject]!) -> Void) {
    
    //predicate to read only running workouts
    let predicate = HKQuery.predicateForWorkouts(with: HKWorkoutActivityType.running)
    
    //order the workouts by date
    let sortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let sampleQuery = HKSampleQuery.init(sampleType: HKSampleType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) in
      
      if error != nil {
        print("There was an error while reading the samples")
      }
      completion(results)
    }
    healthKitStore.execute(sampleQuery)
  }
}




























