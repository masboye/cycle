//
//  User.swift
//  cycle
//
//  Created by boy setiawan on 14/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//


import Foundation
import MapKit
import Firebase

struct User{
    
    private static var dbRef: DatabaseReference = Database.database().reference()
    var userID:String
    var fullName:String
    var activityID:String
    var location:CLLocationCoordinate2D
    let ref: DatabaseReference?
    let key: String
    var point = 0
    var distance = 0.0
    
    init(id: String,fullName:String,activity:String, location: CLLocationCoordinate2D, key: String = "") {
        self.activityID = activity
        self.userID = id
        self.fullName = fullName
        self.location = location
        self.ref = nil
        self.key = key
        self.point = 0
        self.distance = 0.0
    }
    
    init(){
        self.activityID = ""
        self.userID = ""
        self.fullName = ""
        self.location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.ref = nil
        self.key = ""
        self.point = 0
        self.distance = 0.0
    }
    
    init?(snapshot: DataSnapshot) {
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userID = value["userID"] as? String,
            let fullName = value["fullName"] as? String,
            let activityID = value["activity"] as? String,
            let location = value["location"] as? String,
            let point = value["point"] as? Int?,
            let distance = value["distance"] as? Double?
        
            else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.activityID = activityID
        self.userID = userID
        self.fullName = fullName
        self.point = point ?? 0
        self.distance = distance ?? 0.0
        let locationDegrees = location.split(separator: ",")
        
        let userLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationDegrees[0]) as! CLLocationDegrees, longitude: CLLocationDegrees(locationDegrees[1]) as! CLLocationDegrees)
        
        self.location = userLocation
        
    }
    
    func toAnyObject() -> Any {
        
        return [
            "userID": userID,
            "fullName": fullName,
            "activity": activityID,
            "location": "\(location.latitude),\(location.longitude)",
            "point" : point,
            "distance" : distance
            
        ]
    }
    
    func insertData(callback: @escaping (String) -> Void) {
        
        User.dbRef.child("users").childByAutoId().setValue(self.toAnyObject()) { (error, databaseReference) in
            
            if error == nil{
                callback("Operation Successful")
            }else{
                callback(error.debugDescription)
            }
            
        }
    }
    
    func deleteData(callback: (String) -> Void) {
        
        if ref != nil{
            ref?.removeValue()
            callback("Delete Successful")
            
        }else{
            callback("Delete Failed")
            
        }
        
    }
    
    func searchUser(userID:String, callback: @escaping ([User]) -> Void){
        
        
        User.dbRef.child("users").queryOrdered(byChild:  "userID").queryStarting(atValue: userID).queryEnding(atValue: userID + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var userList:[User] = []
            for item in snapshot.children{
                let user = item as! DataSnapshot
                guard let cyclist = User(snapshot: user) else {return}
                userList.append(cyclist)
            }
            
            callback(userList)
            
            
        })
        
    }
    
    func searchActivity(activity:String, callback: @escaping ([User]) -> Void){
        
        
        User.dbRef.child("users").queryOrdered(byChild:  "activity").queryStarting(atValue: activity).queryEnding(atValue: activity + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var userList:[User] = []
            for item in snapshot.children{
                let user = item as! DataSnapshot
                guard let cyclist = User(snapshot: user) else {return}
                userList.append(cyclist)
            }
            
            callback(userList)
            
            
        })
        
    }
}
