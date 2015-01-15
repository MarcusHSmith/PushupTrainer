//
//  HealthManager.swift
//  Pushup
//
//  Created by Marcus Smith on 1/14/15.
//  Copyright (c) 2015 Marcus Smith. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.workoutType()
            ])
        let healthKitTypesToWrite = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKQuantityType.workoutType()
            ])
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil ) {
                completion(success:false, error:error)
            }
            return;
        }
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success,error:error)
            }
        }
    }
    
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        let past = NSDate.distantPast() as NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                let mostRecentSample = results.first as? HKQuantitySample
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func savePushupWorkout(startDate:NSDate , endDate:NSDate , pushups:Double, kiloCalories:Double,
        completion: ( (Bool, NSError!) -> Void)!) {
            let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: pushups/1000)
            let workout = HKWorkout(activityType: HKWorkoutActivityType.TraditionalStrengthTraining, startDate: startDate, endDate: endDate, duration: abs(endDate.timeIntervalSinceDate(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: nil, metadata: nil)
            println(workout)
            healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
                if( error != nil  ) {
                    completion(success,error)
                }
                else {
                    // if success, then save the associated samples so that they appear in the HealthKit
                    let caloriesSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), quantity: caloriesQuantity, startDate: startDate, endDate: endDate)
                    
                    self.healthKitStore.addSamples([caloriesSample], toWorkout: workout, completion: { (success, error ) -> Void in
                        completion(success, error)
                    })
                }
            })
    }
    
    func readPushupWorkOuts(completion: (([AnyObject]!, NSError!) -> Void)!) {
        let predicate =  HKQuery.predicateForWorkoutsWithWorkoutActivityType(HKWorkoutActivityType.TraditionalStrengthTraining)
        // Order the workouts by date
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    println( "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results,error)
        }
        healthKitStore.executeQuery(sampleQuery)
    }
}