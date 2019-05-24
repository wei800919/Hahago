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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

