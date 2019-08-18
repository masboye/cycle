//
//  CyclistView.swift
//  cycle
//
//  Created by boy setiawan on 18/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import MapKit

class CyclistView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let cyclist = newValue as? Cyclist else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // 2
            markerTintColor = cyclist.markerTintColor
            //glyphText = String(artwork.discipline.first!)
            if let imageName = cyclist.imageName {
                glyphImage = UIImage(named: imageName)
            } else {
                glyphImage = nil
            }
        }
    }
}

class ArtworkView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let cyclist = newValue as? Cyclist else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            //rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton
            if let imageName = cyclist.imageName {
                image = UIImage(named: imageName)
            } else {
                image = nil
            }
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = cyclist.subtitle
            detailCalloutAccessoryView = detailLabel
        }
    }
}

