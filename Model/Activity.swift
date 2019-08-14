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
    
    private var activityID:String
    private var routes:[CLLocationCoordinate2D] = []
     let ref: DatabaseReference?
    
    
    init(id: String, routes: [CLLocationCoordinate2D]) {
        self.activityID = id
        self.routes = routes
        self.ref = nil
    }
    
    
    
}
