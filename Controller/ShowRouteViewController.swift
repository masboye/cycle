//
//  ShowRouteViewController.swift
//  cycle
//
//  Created by boy setiawan on 17/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class ShowRouteViewController: UIViewController {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userID:String?
    var messageID = 0
    var friend:Activity!
    var userNeedHelp:User!
    
    var initialLocation:CLLocationCoordinate2D!
    
    private var timerForBackground:Timer?
    @IBAction func sos(_ sender: UIButton) {
        showSOSDialog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let timer = self.timerForBackground else {return}
        timer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.prompt = "Route to \(userNeedHelp.fullName)"
        
        guard let timer = self.timerForBackground else {return}
        backGroundOperation()
        timer.fire()
    }
    
    func showSOSDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "SOS", message: "Message", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            //getting the input values from user
            let message = alertController.textFields?[0].text
            
            let kegiatan = Activity()
            
            let messageID = Int.random(in: 1...10000)
            
            kegiatan.searchActivity(activityID: self.friend.activityID ) { (activities) in
                
                for activity in activities{
                    //update values
                    activity.ref?.updateChildValues(["message" : message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "","user": self.userID ?? "","messageID":messageID])
                    
                }
            }
            
        }
        
        //        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
            
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Message"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //show user location
        mapView.showsUserLocation = true
        //set delegate for mapview
        self.mapView.delegate = self
        
        let defaults = UserDefaults.standard
        self.userID = defaults.string(forKey: "email")
        
        let user = User()
        
        user.searchUser(userID: friend.userID) { (users) in
            self.userNeedHelp = users.first
        }
        
        backGroundOperation()
       
    }
    func backGroundOperation(){
        //background operation
        self.timerForBackground = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (time) in
            
            //check sos message
            let kegiatan = Activity()
            kegiatan.searchActivity(activityID: self.friend.activityID ) { (activities) in
                
                for activity in activities{
                    if  activity.messageID != self.messageID && self.userID != activity.userID { //
                        //new sos message
                        self.showSOSMessage(activity: activity)
                        
                    }
                }
            }
            
            //monitor friends location
            let user = User()
            
            user.searchUser(userID: self.friend.userID) { (users) in
                self.userNeedHelp = users.first
                self.cancelRoutes()
                self.addPinInMap(placemark: self.userNeedHelp.location)
                self.drawRoutes()
            }
            
            
            
        }
    }
    func showSOSMessage(activity:Activity) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let user = User()
        
        user.searchUser(userID: activity.userID) { (users) in
            
            let user = users.first
            
            let info = "\(user?.fullName ?? "a friend") sends a message '\(activity.message)'"
            let alertController = UIAlertController(title: "SOS", message: info, preferredStyle: .alert)
            
            //        //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Acknowledge", style: .cancel) { (_) in
                
                self.messageID = activity.messageID
                
            }
            
            //adding the action to dialogbox
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        }
        //
        
    }
    
}

extension ShowRouteViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.initialLocation = location.coordinate
            self.speedLabel.text = Pretiffy.getSpeed(speed: location.speed)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension ShowRouteViewController: MKMapViewDelegate{
    
    //MARK:- MapKit delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = RandomHelper.generateRandomColor()
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
}

extension ShowRouteViewController{
    
    func addPinInMap(placemark:CLLocationCoordinate2D){
        
        let friendCoordinate = MKPlacemark(coordinate: placemark)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = friendCoordinate.coordinate
        annotation.title = friendCoordinate.name
        if let _ = friendCoordinate.locality,
            let _ = friendCoordinate.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        
    }
    
    
    func cancelRoutes() {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: initialLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
       
    }
    
    func drawRoutes(){

        let sourcePlaceMark = MKPlacemark(coordinate: initialLocation)

        let directionRequest = MKDirections.Request()
        let source = MKMapItem(placemark: sourcePlaceMark)
        let friendCoordinate = MKPlacemark(coordinate: userNeedHelp.location)

            directionRequest.source = source
            directionRequest.destination = MKMapItem(placemark: friendCoordinate)
            directionRequest.transportType = .walking

            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let directionResonse = response else {
                    if let error = error {
                        print("we have error getting directions==\(error.localizedDescription)")
                    }
                    return
                }

                //get route and assign to our route variable
                let route = directionResonse.routes[0]

                //test
                print("route.distance = \(Pretiffy.getDistance(distance: route.distance))")
                self.distanceLabel.text = "Distance \(Pretiffy.getDistance(distance: route.distance))"
                //end

                //add rout to our mapview
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                //setting rect of our mapview to fit the two locations
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }

           


    }

}
