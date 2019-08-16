//
//  PretiffyDistance.swift
//  cycle
//
//  Created by boy setiawan on 16/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

struct Pretiffy {
    
    static func getDistance(distance:Double) -> String {
        
        let lengthFormatter = LengthFormatter()
        
        if distance > 1000{
            return "\(lengthFormatter.string(fromValue:distance, unit: .kilometer))"
        }else{
            return "\(lengthFormatter.string(fromValue:distance, unit: .meter))"
        }
        
    }
    
    static func getAltitude(height:Double) -> String {
        
        let lengthFormatter = LengthFormatter()
        return "\(lengthFormatter.string(fromValue:height, unit: .meter))"
        
    }
    
    static func getSpeed(speed:Double) -> String {
        
        let lengthFormatter = LengthFormatter()
//        lengthFormatter.numberFormatter.roundingMode = .ceiling
//        lengthFormatter.numberFormatter.maximumFractionDigits = 2
//        
        if speed < 0{
            return "0"
        }
        
        let calculatedSpeed = speed * 3600
        //print("speed \(speed) - calculated \(calculatedSpeed) ")
        return "\(lengthFormatter.string(fromValue:calculatedSpeed, unit: .kilometer))/hour"
       
    }
}
