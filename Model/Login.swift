//
//  Login.swift
//  cycle
//
//  Created by boy setiawan on 14/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

import Firebase

struct User{
    
    private var userID:String
    private var fullName:String
    private var activityID:String
    private var location:CLLocationCoordinate2D
    private let ref: DatabaseReference?
    let key: String
    
    init(id: String,fullName:String,activity:String, location: CLLocationCoordinate2D, key: String = "") {
        self.activityID = activity
        self.userID = id
        self.fullName = fullName
        self.location = location
        self.ref = nil
        self.key = key
    }
    
    init?(snapshot: DataSnapshot) {
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userID = value["userID"] as? String,
            let fullName = value["fullName"] as? String,
            let activityID = value["activityID"] as? String,
            let location = value["location"] as? String
            
            else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.activityID = activityID
        self.userID = userID
        self.fullName = fullName
        let locationDegrees = location.split(separator: ",")
        
        let userLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationDegrees[0]) as! CLLocationDegrees, longitude: CLLocationDegrees(locationDegrees[1]) as! CLLocationDegrees)
        
        self.location = userLocation
        
    }
    
    func toAnyObject() -> Any {
        
        return [
            "userID": userID,
            "fullName": fullName,
            "activity": activityID,
            "location": "\(location.latitude),\(location.longitude)"
            
        ]
    }
}
