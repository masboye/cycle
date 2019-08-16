//
//  Activity.swift
//  cycle
//
//  Created by boy setiawan on 14/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import MapKit
import Firebase

struct Activity{
    
    private static var dbRef: DatabaseReference = Database.database().reference()
    var activityID:String
    var routes:[CLLocationCoordinate2D] = []
    var messageID = 0
    var message:String
    var userID:String
    let ref: DatabaseReference?
    private var key: String
    
    init(id: String, routes: [CLLocationCoordinate2D], key: String = "") {
        self.activityID = id
        self.routes = routes
        self.ref = nil
        self.key = key
        self.message = ""
        self.userID = ""
        
    }
    
    init(){
        self.activityID = ""
        self.routes = []
        self.ref = nil
        self.key = ""
        self.message = ""
        self.userID = ""
    }
    
    init?(snapshot: DataSnapshot) {
        
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let activityID = value["activityID"] as? String,
            let routes = value["routes"] as? [String],
            let messageID = value["messageID"] as? Int?,
            let message = value["message"] as? String,
            let user = value["user"] as? String
            else {
                return nil
            }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.activityID = activityID
        self.message = message
        self.messageID = messageID ?? 0
        self.userID = user
        
        var routesList :[CLLocationCoordinate2D] = []
        routes.forEach { (route) in
            let location = route.split(separator: ",")
            routesList.append(CLLocationCoordinate2D(latitude: Double(location[0]) as! CLLocationDegrees, longitude: Double(location[1]) as! CLLocationDegrees))
        }
        
        self.routes = routesList
        
    }
    
    func toAnyObject() -> Any {
        
        var routesList:[String] = []
        
        for route in routes {
            routesList.append("\(route.latitude),\(route.longitude)")
            
        }
        
        return [
            "activityID": activityID,
            "routes": routesList,
            "messageID": messageID,
            "message": message,
            "user": userID
            
        ]
    }
    
    func insertData(callback: @escaping (String) -> Void) {
        
        Activity.dbRef.child("activities").childByAutoId().setValue(self.toAnyObject()) { (error, databaseReference) in
            
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
    
    func searchActivity(activityID:String, callback: @escaping ([Activity]) -> Void){
        
        
        Activity.dbRef.child("activities").queryOrdered(byChild:  "activityID").queryStarting(atValue: activityID).queryEnding(atValue: activityID + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var activityList:[Activity] = []
            for item in snapshot.children{
                let activity = item as! DataSnapshot
                
                guard let activityCyclist = Activity(snapshot: activity) else {return}
                activityList.append(activityCyclist)
            }
            
            callback(activityList)
           
            
        })
        
    }
}



