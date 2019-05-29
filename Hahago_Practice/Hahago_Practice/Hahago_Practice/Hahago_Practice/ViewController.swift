//
//  ViewController.swift
//  Hahago_Practice
//
//  Created by honeywld on 2019/5/20.
//  Copyright © 2019 honeywld. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion

class ViewController: UIViewController {
    
    let pedonmeter:CMPedometer = CMPedometer()
    var healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
    }
    
    func authoriztion(){
        // 判读是否支持‘健康’
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: dataTypesRead()) { (isAuthorize, error) in
                print(isAuthorize)
                print(error)
            }
        } else {
            print("can't support!")
        }
    }
    
    private func dataTypesRead() -> Set<HKObjectType>? {
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else { return nil }
        
        var set = Set<HKObjectType>()
        set.insert(stepCount)
        set.insert(distance)
        
        return set
    }
    
    func getStepCount(){
        if CMPedometer.isStepCountingAvailable(){
            //開始時間
            let startTime = getStartTime()
            //結束時間
            let endTime = getEndTime()
            //第一種
            //獲取一個時間範圍內的資料最大7天  引數 開始時間,結束時間, 一個閉包
            pedonmeter.queryPedometerData(from: startTime, to: endTime) { (pedometerData, error) in
                if error != nil{
                    print("error:\(error)")
                }
                else{
                    print("開始時間:\(startTime)")
                    print("結束時間:\(endTime)")
                    print("步數===\(pedometerData!.numberOfSteps)")
                    print("距離===\(pedometerData!.distance)")
                }
            }
        }
    }
    
    func getStepCountFromAPP(){
        let healthStore: HKHealthStore? = {
            if HKHealthStore.isHealthDataAvailable() {
                return HKHealthStore()
            } else {
                return nil
            }
        }()
        
        
        
        let stepsCount = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let dataTypesToWrite = NSSet(object: stepsCount)
        let dataTypesToRead = NSSet(object: stepsCount)
        
        healthStore?.requestAuthorization(toShare: nil ,
                                          read: dataTypesToRead as! Set<HKObjectType>,
                                          completion: { [unowned self] (success, error) in
                                            if success {
                                                print("success")
                                            } else {
                                                print(error.debugDescription)
                                            }
        })
        
        let now = Date()
        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: 0), to: now)!
        let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
        let predicate = HKQuery.predicateForSamples(withStart: startOfSevenDaysAgo, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepsCount!,
                                                     quantitySamplePredicate: predicate,
                                                     options: .cumulativeSum,
                                                     anchorDate: startOfSevenDaysAgo,
                                                     intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                // Perform proper error handling here...
                return
            }
            
            statsCollection.enumerateStatistics(from: startOfSevenDaysAgo, to: now) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let stepValue = quantity.doubleValue(for: HKUnit.count())
                    print(stepValue)
                }
            }
        }
        
        // Don't forget to execute the Query!
        healthStore?.execute(query)
    }
    
    func getStartTime() -> Date {
        let datef = DateFormatter()
        datef.dateFormat = "yyyy-MM-dd"
        let stringdate = datef.string(from: getEndTime())
        print("當天日期:\(stringdate)")
        let tdate = datef.date(from: stringdate)
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT(for: tdate!)
        let nowday = tdate!.addingTimeInterval(TimeInterval(interval))
        return nowday
    }
    
    func getEndTime() -> Date {
        let date = Date()
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT(for: date)
        let nowDate = date.addingTimeInterval(TimeInterval(interval))
        return nowDate
    }
}

