//
//  Cyclist.swift
//  cycle
//
//  Created by boy setiawan on 18/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import MapKit
import Contacts

class Cyclist: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let userID: String
    let discipline: String
    
    init(fullname: String, userID: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = fullname
        self.userID = userID
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    init?(user: User) {
       self.title = user.fullName
        self.userID = user.userID
        self.discipline = "Flag"
        self.coordinate = user.location
    }
    
    var subtitle: String? {
        return userID
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    // markerTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    var markerTintColor: UIColor  {
        switch discipline {
        case "Monument":
            return .red
        case "Mural":
            return .cyan
        case "Plaque":
            return .blue
        case "Sculpture":
            return .purple
        default:
            return .green
        }
    }
    
    var imageName: String? {
        if discipline == "Sculpture" { return "Statue" }
        return "Flag"
    }

}
